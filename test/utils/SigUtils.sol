// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Execution, ExecutionLib} from "src/lib/Call.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";


contract SigUtils {
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes internal constant CALL_TYPESTRING = "Execution(address target,uint256 value,bytes callData)";

    bytes private constant EXECUTEBATCH_TYPESTRING =
    "ExecuteBatch(Execution[] calls,uint256 nonce,uint256 deadline)";

    bytes32 private constant EXECUTEBATCH_TYPEHASH =
        keccak256(abi.encodePacked(EXECUTEBATCH_TYPESTRING, ExecutionLib.CALL_TYPESTRING));

    // computes the hash of a permit
    function getStructHash(
        Execution[] memory _calls,
        uint256 _nonce,
        uint256 _deadline
    ) internal pure returns (bytes32 structHash) {
        structHash = keccak256(
            abi.encode(EXECUTEBATCH_TYPEHASH, ExecutionLib.hashCallArray(_calls), _nonce, _deadline)
        );
        return structHash;
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(
        address wallet,
        Execution[] memory _calls,
        uint256 _nonce,
        uint256 _deadline
    ) public view returns (bytes32) {
        return
            ECDSA.toTypedDataHash(walletDomain(wallet), getStructHash(_calls, _nonce, _deadline));
    }

    function walletDomain(address wallet) internal view returns (bytes32) {
        bytes32 _hashedName = keccak256(bytes("Supa wallet"));
        bytes32 _hashedVersion = keccak256(bytes(WalletLogic(wallet).VERSION()));
        bytes32 _domainSeparatorV4 = keccak256(
            abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, wallet)
        );
        return _domainSeparatorV4;
    }
}
