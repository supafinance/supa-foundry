// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {IPermit2} from "src/external/interfaces/IPermit2.sol";
import {TransferAndCall2} from "src/supa/TransferAndCall2.sol";
import {TestERC20} from "src/testing/TestERC20.sol";
import {TestNFT} from "src/testing/TestNFT.sol";
import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {MockNFTOracle} from "src/testing/MockNFTOracle.sol";
import {Supa, ISupa} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {WalletLogic, LinkedCall, ReturnDataLink} from "src/wallet/WalletLogic.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {Call, CallLib} from "src/lib/Call.sol";
import {ITransferReceiver2} from "src/interfaces/ITransferReceiver2.sol";

import {SigUtils, ECDSA} from "test/utils/SigUtils.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract WalletTest is Test {
    IPermit2 public permit2;
    TransferAndCall2 public transferAndCall2;

    TestERC20 public usdc;
    TestERC20 public weth;
    TestNFT public nft;
    TestNFT public unregisteredNFT;

    MockERC20Oracle public usdcChainlink;
    MockERC20Oracle public ethChainlink;

    MockNFTOracle public nftOracle;

    Supa public supa;
    SupaConfig public supaConfig;
    VersionManager public versionManager;
    WalletLogic public proxyLogic;

    WalletProxy public treasuryWallet;
    WalletProxy public userWallet;

    bytes32 public constant FS_SALT = bytes32(0x1234567890123456789012345678901234567890123456789012345678901234);

    string public constant VERSION = "1.0.0";

    function setUp() public {
        address owner = address(this);

        usdc = new TestERC20("Circle USD", "USDC", 6);
        weth = new TestERC20("Wrapped Ether", "WETH", 18);
        nft = new TestNFT("Test NFT", "TNFT", 0);
        unregisteredNFT = new TestNFT("Unregistered NFT", "UNFT", 0);

        usdcChainlink = new MockERC20Oracle(owner);
        ethChainlink = new MockERC20Oracle(owner);

        nftOracle = new MockNFTOracle();

        versionManager = new VersionManager(owner);
        supaConfig = new SupaConfig(owner);
        supa = new Supa(address(supaConfig), address(versionManager));
        proxyLogic = new WalletLogic(address(supa));

        ISupaConfig(address(supa)).setConfig(
            ISupaConfig.Config({
                treasuryWallet: address(0),
                treasuryInterestFraction: 0,
                maxSolvencyCheckGasCost: 10_000_000,
                liqFraction: 8e17,
                fractionalReserveLeverage: 10
            })
        );

        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(proxyLogic));
        versionManager.markRecommendedVersion(VERSION);

        transferAndCall2 = TransferAndCall2(0x1554b484D2392672F0375C56d80e91c1d070a007);
        vm.etch(address(transferAndCall2), type(TransferAndCall2).creationCode);
        // transferAndCall2 = new TransferAndCall2{salt: FS_SALT}();
        usdc.approve(address(transferAndCall2), type(uint256).max);
        weth.approve(address(transferAndCall2), type(uint256).max);
    }

    function testExecuteBatchLink() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        deal({token: address(weth), to: address(this), give: 10 ether});
        deal({token: address(weth), to: address(userWallet), give: 10 ether});

        LinkedCall[] memory linkedCalls = new LinkedCall[](2);
        ReturnDataLink[] memory links = new ReturnDataLink[](1);
        links[0] = ReturnDataLink({
            returnValueOffset: 0,
            isStatic: true,
            callIndex: 0,
            offset: 4
        });
        linkedCalls[0] = LinkedCall({
            call: Call({
                to: address(supa),
                callData: abi.encodeWithSignature("getWalletOwner(address)", address(userWallet)),
                value: 0
            }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[1] = LinkedCall({
            call: Call({
                to: address(weth),
                callData: abi.encodeWithSignature("transfer(address,uint256)", address(0), 1 ether),
                value: 0
            }),
            links: links
        });

        WalletLogic(address(userWallet)).executeBatchLink(linkedCalls);
    }

    function testExecuteBatchLinkMulticall() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        deal({token: address(weth), to: address(this), give: 10 ether});
        deal({token: address(weth), to: address(userWallet), give: 10 ether});

        LinkedCall[] memory linkedCalls = new LinkedCall[](2);
        ReturnDataLink[] memory links = new ReturnDataLink[](1);
        links[0] = ReturnDataLink({
            returnValueOffset: 0,
            isStatic: true,
            callIndex: 0,
            offset: 4
        });
        linkedCalls[0] = LinkedCall({
            call: Call({
            to: address(supa),
            callData: abi.encodeWithSignature("getWalletOwner(address)", address(userWallet)),
            value: 0
        }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[1] = LinkedCall({
            call: Call({
            to: address(weth),
            callData: abi.encodeWithSignature("transfer(address,uint256)", address(0), 1 ether),
            value: 0
        }),
            links: links
        });

        WalletLogic(address(userWallet)).executeBatchLink(linkedCalls);
    }

    function testValidExecuteSignedBatch() public {
        SigUtils sigUtils = new SigUtils();
        uint256 userPrivateKey = 0xB0B;
        address user = vm.addr(userPrivateKey);
        vm.prank(user);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        Call[] memory calls = new Call[](0);
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;

        bytes32 digest = sigUtils.getTypedDataHash(address(userWallet), calls, nonce, deadline);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // address recovered = ecrecover(digest, v, r, s);

        WalletLogic(address(userWallet)).executeSignedBatch(calls, nonce, deadline, signature);
    }

    function testExecuteSignedBatchReplay() public {
        SigUtils sigUtils = new SigUtils();
        uint256 userPrivateKey = 0xB0B;
        address user = vm.addr(userPrivateKey);
        vm.prank(user);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        WalletProxy userWallet2 = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        Call[] memory calls = new Call[](0);
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;

        bytes32 digest = sigUtils.getTypedDataHash(address(userWallet), calls, nonce, deadline);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // address recovered = ecrecover(digest, v, r, s);

        WalletLogic(address(userWallet)).executeSignedBatch(calls, nonce, deadline, signature);
        vm.expectRevert(WalletLogic.InvalidSignature.selector);
        WalletLogic(address(userWallet2)).executeSignedBatch(calls, nonce, deadline, signature);
    }

    function testTransferAndCall2ToProxy() public {
        // TODO

        deal({token: address(usdc), to: address(this), give: 10_000 * 1e6});

        deal({token: address(weth), to: address(this), give: 1 * 1 ether});

        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        ITransferReceiver2.Transfer[] memory transfers = new ITransferReceiver2.Transfer[](2);

        transfers[0] = ITransferReceiver2.Transfer({token: address(usdc), amount: 10_000 * 1e6});

        transfers[1] = ITransferReceiver2.Transfer({token: address(weth), amount: 1 * 1 ether});

        _sortTransfers(transfers);

        bytes memory data = bytes("0x");
        transferAndCall2.transferAndCall2(address(userWallet), transfers, data);
    }

    function testTransferAndCall2ToSupa() public {
        // TODO
    }

    function testTransferAndCall2WithSwap() public {
        // TODO
    }

    function testUpgradeVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeInvalidVersion(string memory invalidVersionName) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        if (keccak256(abi.encodePacked(invalidVersionName)) == keccak256(abi.encodePacked(VERSION))) {
            invalidVersionName = "1.0.1";
        }
        vm.expectRevert();
        _upgradeWalletImplementation(invalidVersionName);
    }

    function testUpgradeDeprecatedVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.DEPRECATED, IVersionManager.BugLevel.NONE);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeLowBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.LOW);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeMedBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.MEDIUM);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeHighBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.HIGH);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeCriticalBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.CRITICAL);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testProposeTransferWalletOwnership(address newOwner) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        Call[] memory calls = new Call[](1);
        calls[0] = Call({
            to: address(supa),
            callData: abi.encodeWithSignature("proposeTransferWalletOwnership(address)", newOwner),
            value: 0
        });
        userWallet.executeBatch(calls);
        address proposedOwner = SupaConfig(address(supa)).walletProposedNewOwner(address(userWallet));
        assert(proposedOwner == newOwner);
    }

    function testExecuteTransferWalletOwnership(address newOwner) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        Call[] memory calls = new Call[](1);
        calls[0] = Call({
            to: address(supa),
            callData: abi.encodeWithSignature("proposeTransferWalletOwnership(address)", newOwner),
            value: 0
        });
        userWallet.executeBatch(calls);

        vm.prank(newOwner);
        ISupa(address(supa)).executeTransferWalletOwnership(address(userWallet));

        address actualOwner = ISupa(address(supa)).getWalletOwner(address(userWallet));
        assert(actualOwner == newOwner);
    }

    function testExecuteInvalidOwnershipTransfer(address newOwner) public {
        vm.assume(newOwner != address(0));
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        vm.prank(newOwner);
        vm.expectRevert();
        ISupa(address(supa)).executeTransferWalletOwnership(address(userWallet));
    }

    function _setupWallets() internal {
        treasuryWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    }

    function _upgradeWalletImplementation(string memory versionName) internal {
        Call[] memory calls = new Call[](1);
        calls[0] = Call({
            to: address(supa),
            callData: abi.encodeWithSignature("upgradeWalletImplementation(string)", versionName),
            value: 0
        });
        userWallet.executeBatch(calls);
    }

    function _sortTransfers(ITransferReceiver2.Transfer[] memory transfers) internal pure {
        for (uint256 i = 0; i < transfers.length; i++) {
            for (uint256 j = i + 1; j < transfers.length; j++) {
                if (transfers[i].token > transfers[j].token) {
                    ITransferReceiver2.Transfer memory temp = transfers[i];
                    transfers[i] = transfers[j];
                    transfers[j] = temp;
                }
            }
        }
    }
}
