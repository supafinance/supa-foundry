// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {WalletState} from "./WalletState.sol";
import {Liquifier} from "../supa/Liquifier.sol";
import {IVersionManager} from "../interfaces/IVersionManager.sol";
import {ITransferReceiver2} from "../interfaces/ITransferReceiver2.sol";
import {ISupa} from "../interfaces/ISupa.sol";
import {WalletProxy} from "./WalletProxy.sol";
import {IWallet} from "../interfaces/IWallet.sol";
import {IERC1363SpenderExtended} from "../interfaces/IERC1363-extended.sol";
import {CallLib, Call, LinkedCall, ReturnDataLink} from "../lib/Call.sol";
import {NonceMapLib, NonceMap} from "../lib/NonceMap.sol";
import {ImmutableVersion} from "../lib/ImmutableVersion.sol";
import {BytesLib} from "../lib/BytesLib.sol";

// Calls to the contract not coming from Supa itself are routed to this logic
// contract. This allows for flexible extra addition to your wallet.
contract WalletLogic is
//    WalletState,
    ImmutableVersion,
    IERC721Receiver,
    IERC1271,
    ITransferReceiver2,
    EIP712,
    IWallet,
//    Liquifier,
    IERC1363SpenderExtended
{
    using NonceMapLib for NonceMap;
    using BytesLib for bytes;

    bytes private constant EXECUTEBATCH_TYPESTRING =
        "ExecuteBatch(Call[] calls,uint256 nonce,uint256 deadline)";
    bytes private constant TRANSFER_TYPESTRING = "Transfer(address token,uint256 amount)";
    bytes private constant ONTRANSFERRECEIVED2CALL_TYPESTRING =
        "OnTransferReceived2Call(address operator,address from,Transfer[] transfers,Call[] calls,uint256 nonce,uint256 deadline)";

    bytes32 private constant EXECUTEBATCH_TYPEHASH =
        keccak256(abi.encodePacked(EXECUTEBATCH_TYPESTRING, CallLib.CALL_TYPESTRING));
    bytes32 private constant TRANSFER_TYPEHASH = keccak256(TRANSFER_TYPESTRING);
    bytes32 private constant ONTRANSFERRECEIVED2CALL_TYPEHASH =
        keccak256(
            abi.encodePacked(
                ONTRANSFERRECEIVED2CALL_TYPESTRING,
                CallLib.CALL_TYPESTRING,
                TRANSFER_TYPESTRING
            )
        );

    string public constant VERSION = "1.3.2";

    bool internal forwardNFT;
    NonceMap private nonceMap;

    /// @notice Data does not match the expected format
    error InvalidData();
    /// @notice Signature is invalid
    error InvalidSignature();
    /// @notice Nonce has already been used
    error NonceAlreadyUsed();
    /// @notice Deadline has expired
    error DeadlineExpired();
    /// @notice Only Supa can call this function
    error OnlySupa();
    /// @notice Only the owner or operator can call this function
    error NotOwnerOrOperator();
    /// @notice Only the owner can call this function
    error OnlyOwner();
    /// @notice Only this address can call this function
    error OnlyThisAddress();
    /// @notice The wallet is insolvent
    error Insolvent();
    /// @notice Transfer failed
    error TransferFailed();

    modifier onlyOwner() {
        if (_supa().getWalletOwner(address(this)) != msg.sender) {
            revert OnlyOwner();
        }
        _;
    }

    modifier onlyOwnerOrOperator() {
        if (
            _supa().getWalletOwner(address(this)) != msg.sender &&
            !_supa().isOperator(address(this), msg.sender)
        ) {
            revert NotOwnerOrOperator();
        }
        _;
    }

    modifier onlyThisAddress() {
        if (msg.sender != address(this)) {
            revert OnlyThisAddress();
        }
        _;
    }

    modifier onlySupa() {
        if (msg.sender != address(_supa())) {
            revert OnlySupa();
        }
        _;
    }

    // Note EIP712 is implemented with immutable variables and is not using
    // storage and thus can be used in a proxy contract constructor.
    // Version number should be in sync with VersionManager version.
    constructor(
    ) EIP712("Supa wallet", VERSION) ImmutableVersion(VERSION) {
    }

    /// @notice Transfer ETH
    function transfer(address to, uint256 value) external payable onlyThisAddress {
        (bool success, ) = to.call{value: value}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    /// @notice makes a batch of different calls from the name of wallet owner. Eventual state of
    /// creditAccount and Supa must be solvent, i.e. debt on creditAccount cannot exceed collateral on
    /// creditAccount and wallet and Supa reserve/debt must be sufficient
    /// @dev - this goes to supa.executeBatch that would immediately call WalletProxy.executeBatch
    /// from above of this file
    /// @param calls {address to, bytes callData, uint256 value}[], where
    ///   * to - is the address of the contract whose function should be called
    ///   * callData - encoded function name and it's arguments
    ///   * value - the amount of ETH to sent with the call
    function executeBatch(Call[] calldata calls) external payable onlyOwnerOrOperator {
        bool saveForwardNFT = forwardNFT;
        forwardNFT = false;
        CallLib.executeBatch(calls);
        forwardNFT = saveForwardNFT;

        if (!_supa().isSolvent(address(this))) {
            revert Insolvent();
        }
    }

    function executeSignedBatch(
        Call[] memory calls,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external payable {
        if (deadline < block.timestamp) revert DeadlineExpired();
        nonceMap.validateAndUseNonce(nonce);
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(EXECUTEBATCH_TYPEHASH, CallLib.hashCallArray(calls), nonce, deadline)
            )
        );
        if (
            !SignatureChecker.isValidSignatureNow(
            _supa().getWalletOwner(address(this)),
                digest,
                signature
            )
        ) revert InvalidSignature();

        _supa().executeBatch(calls);
    }

    function forwardNFTs(bool _forwardNFT) external {
        if (msg.sender != address(this)) {
            revert OnlyThisAddress();
        }
        forwardNFT = _forwardNFT;
    }

    /// @notice ERC721 transfer callback
    /// @dev it's a callback, required to be implemented by IERC721Receiver interface for the
    /// contract to be able to receive ERC721 NFTs.
    /// we are already using it to support "forwardNFT" of wallet.
    /// `return this.onERC721Received.selector;` is mandatory part for the NFT transfer to work -
    /// not a part of owr business logic
    /// @param - operator The address which called `safeTransferFrom` function
    /// @param - from The address which previously owned the token
    /// @param tokenId The NFT identifier which is being transferred
    /// @param data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 tokenId,
        bytes memory data
    ) public virtual override returns (bytes4) {
        if (forwardNFT) {
            IERC721(msg.sender).safeTransferFrom(address(this), address(_supa()), tokenId, data);
        }
        return this.onERC721Received.selector;
    }

    function setNonce(uint256 nonce) external onlyOwner {
        nonceMap.validateAndUseNonce(nonce);
    }

    /// @inheritdoc ITransferReceiver2
    function onTransferReceived2(
        address operator,
        address from,
        ITransferReceiver2.Transfer[] calldata transfers,
        bytes calldata data
    ) external override onlyTransferAndCall2 returns (bytes4) {
        // options:
        // 1) just deposit into proxy, nothing to do
        // 2) execute a batch of calls (msg.sender is owner)
        // 3) directly deposit into supa contract
        // 3) execute a signed batch of tx's
        if (data.length == 0) {
            /* just deposit in the proxy, nothing to do */
        } else if (data[0] == 0x00) {
            // execute batch
            if (msg.sender != _supa().getWalletOwner(address(this))) {
                revert OnlyOwner();
            }
            Call[] memory calls = abi.decode(data[1:], (Call[]));
            _supa().executeBatch(calls);
        } else if (data[0] == 0x01) {
            if (data.length != 1) revert InvalidData();
            // deposit in the supa wallet
            for (uint256 i = 0; i < transfers.length; i++) {
                ITransferReceiver2.Transfer memory transfer_ = transfers[i];
                _supa().depositERC20(IERC20(transfer_.token), transfer_.amount);
            }
        } else if (data[0] == 0x02) {
            // execute signed batch

            // Verify signature matches
            (Call[] memory calls, uint256 nonce, uint256 deadline, bytes memory signature) = abi
                .decode(data[1:], (Call[], uint256, uint256, bytes));

            if (deadline < block.timestamp) revert DeadlineExpired();
            nonceMap.validateAndUseNonce(nonce);

            bytes32[] memory transferDigests = new bytes32[](transfers.length);
            for (uint256 i = 0; i < transfers.length; i++) {
                transferDigests[i] = keccak256(
                    abi.encode(TRANSFER_TYPEHASH, transfers[i].token, transfers[i].amount)
                );
            }
            bytes32 digest = _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        ONTRANSFERRECEIVED2CALL_TYPEHASH,
                        operator,
                        from,
                        keccak256(abi.encodePacked(transferDigests)),
                        CallLib.hashCallArray(calls),
                        nonce,
                        deadline
                    )
                )
            );
            if (
                !SignatureChecker.isValidSignatureNow(
                _supa().getWalletOwner(address(this)),
                    digest,
                    signature
                )
            ) revert InvalidSignature();

            _supa().executeBatch(calls);
        } else {
            revert("Invalid data - allowed are '', '0x00...', '0x01' and '0x02...'");
        }
        return ITransferReceiver2.onTransferReceived2.selector;
    }

    function onApprovalReceived(
        address sender,
        uint256 amount,
        Call memory call
    ) external onlySupa returns (bytes4) {
        if (call.callData.length == 0) {
            revert InvalidData();
        }
        emit TokensApproved(sender, amount, call.callData);

        Call[] memory calls = new Call[](1);
        calls[0] = call;

        _supa().executeBatch(calls);

        return this.onApprovalReceived.selector;
    }

    function owner() external view returns (address) {
        return _supa().getWalletOwner(address(this));
    }

    /// @inheritdoc IERC1271
    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) public view override returns (bytes4 magicValue) {
        magicValue = SignatureChecker.isValidSignatureNow(
            _supa().getWalletOwner(address(this)),
            hash,
            signature
        )
            ? this.isValidSignature.selector
            : bytes4(0);
    }

    function valueNonce(uint256 nonce) external view returns (bool) {
        return nonceMap.getNonce(nonce);
    }

    /// @notice Execute a batch of calls with linked return values.
    /// @param linkedCalls The calls to execute.
    function executeBatchLink(LinkedCall[] memory linkedCalls) external payable onlyOwnerOrOperator {
        bool saveForwardNFT = forwardNFT;
        forwardNFT = false;

        // todo: add checks for linkedCalls
        // 1. callIndex must be less than the current call

        // get the first call
        Call memory call;

        // create a bytes array with length equal to the number of calls
        bytes[] memory returnDataArray = new bytes[](linkedCalls.length);

        // loop through the calls
        uint256 l = linkedCalls.length;
        for (uint256 i = 0; i < l;) {

            // get the next call to execute
            call = linkedCalls[i].call;

            // loop through the offsets (the number of return values to be passed in the next call)
            uint256 linksLength = linkedCalls[i].links.length;
            for (uint256 j = 0; j < linksLength;) {

                ReturnDataLink memory link = linkedCalls[i].links[j];

                // get the call index, offset, and linked return value
                uint32 callIndex = link.callIndex;
                uint128 offset = link.offset;
                uint32 returnValueOffset = link.returnValueOffset;
                bool isStatic = link.isStatic;

                // revert if call has NOT already been executed
                if (callIndex > i) {
                    revert InvalidData();
                }

                bytes memory spliceCalldata;

                if (isStatic) {
                    // get the variable of interest from the return data
                    spliceCalldata = returnDataArray[callIndex].slice(returnValueOffset, 32);
                } else {
                    uint256 pointer = uint256(bytes32(returnDataArray[callIndex].slice(returnValueOffset, 32)));
                    uint256 len = uint256(bytes32(returnDataArray[callIndex].slice(pointer, 32)));
                    spliceCalldata = returnDataArray[callIndex].slice(pointer + 32, len);
                }

                bytes memory callData = call.callData;

                // splice the variable into the next call's calldata
                bytes memory prebytes = callData.slice(0, offset);
                bytes memory postbytes = callData.slice(offset + 32, callData.length - offset - 32);
                bytes memory newCallData = prebytes.concat(spliceCalldata.concat(postbytes));

                call.callData = newCallData;

                // increment the return value index
                unchecked {
                    j++;
                }
            }

            // execute the call and store the return data
            bytes memory returnData = CallLib.execute(call);
            // add the return data to the array
            returnDataArray[i] = returnData;

            // increment the call index
            unchecked {
                i++;
            }
        }

        forwardNFT = saveForwardNFT;

        if (!_supa().isSolvent(address(this))) {
            revert Insolvent();
        }
    }

    function _supa() internal view returns (ISupa) {
        return WalletProxy(payable(address(this))).supa();
    }
}
