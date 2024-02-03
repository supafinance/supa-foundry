// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import { Vm, VmSafe } from "forge-std/Vm.sol";

import {IPermit2} from "src/external/interfaces/IPermit2.sol";
import {TransferAndCall2} from "src/supa/TransferAndCall2.sol";
import {TestERC20} from "src/testing/TestERC20.sol";
import {TestNFT} from "src/testing/TestNFT.sol";
import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {MockNFTOracle} from "src/testing/MockNFTOracle.sol";
import {Supa} from "src/supa/Supa.sol";
import {ISupa} from "src/interfaces/ISupa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {WalletLogic, LinkedExecution, ReturnDataLink} from "src/wallet/WalletLogic.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {Execution, ExecutionLib} from "src/lib/Call.sol";
import {ITransferReceiver2} from "src/interfaces/ITransferReceiver2.sol";

import {Errors} from "src/libraries/Errors.sol";

import {SigUtils, ECDSA} from "test/utils/SigUtils.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WalletTest is Test {
    IPermit2 public permit2;
    TransferAndCall2 public transferAndCall2;

    TestNFT public nft;
    TestNFT public unregisteredNFT;

    MockNFTOracle public nftOracle;

    Supa public supa;
    SupaConfig public supaConfig;
    VersionManager public versionManager;
    WalletLogic public proxyLogic;

    address public user;
    address public governance;
    WalletProxy public treasuryWallet;
    WalletProxy public userWallet;

    // Create 2 tokens
    TestERC20 public token0;
    TestERC20 public token1;

    MockERC20Oracle public token0Oracle;
    MockERC20Oracle public token1Oracle;

    bytes32 public constant FS_SALT = bytes32(0x1234567890123456789012345678901234567890123456789012345678901234);

    function setUp() public {
        address owner = address(this);
        user = address(this);
        governance = address(this);

        // deploy Supa contracts
        versionManager = new VersionManager(owner);
        supaConfig = new SupaConfig(owner);
        supa = new Supa(address(supaConfig), address(versionManager));
        proxyLogic = new WalletLogic();
        string memory VERSION = proxyLogic.VERSION();

        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(proxyLogic));
        versionManager.markRecommendedVersion(VERSION);

        ISupaConfig(address(supa)).setConfig(
            ISupaConfig.Config({
                treasuryWallet: address(0),
                treasuryInterestFraction: 0,
                maxSolvencyCheckGasCost: 10_000_000,
                liqFraction: 0.8 ether,
                fractionalReserveLeverage: 10
            })
        );

        ISupaConfig(address(supa)).setTokenStorageConfig(
            ISupaConfig.TokenStorageConfig({maxTokenStorage: 250, erc20Multiplier: 1, erc721Multiplier: 1})
        );


        // setup tokens
        token0 = new TestERC20("token0", "t0", 18);
        token1 = new TestERC20("token1", "t1", 18);

        token0Oracle = new MockERC20Oracle(owner);
        token0Oracle.setPrice(1e18, 18, 18);
        token0Oracle.setRiskFactors(9e17, 9e17);

        token1Oracle = new MockERC20Oracle(owner);
        token1Oracle.setPrice(1e18, 18, 18);
        token1Oracle.setRiskFactors(9e17, 9e17);
    }

    function testExecuteBatchLinkTransfer() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        deal({token: address(token0), to: address(this), give: 10 ether});
        deal({token: address(token0), to: address(userWallet), give: 10 ether});

        LinkedExecution[] memory linkedCalls = new LinkedExecution[](2);
        ReturnDataLink[] memory links = new ReturnDataLink[](1);
        links[0] = ReturnDataLink({
            returnValueOffset: 0,
            isStatic: true,
            callIndex: 0,
            offset: 4
        });
        linkedCalls[0] = LinkedExecution({
            execution: Execution({
                target: address(supa),
                value: 0,
                callData: abi.encodeWithSignature("getWalletOwner(address)", address(userWallet))
            }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[1] = LinkedExecution({
            execution: Execution({
                target: address(token0),
                value: 0,
                callData: abi.encodeWithSignature("transfer(address,uint256)", address(0), 1 ether)
            }),
            links: links
        });

        WalletLogic(address(userWallet)).executeBatchLink(linkedCalls);
    }

    function testValidExecuteSignedBatch() public {
        SigUtils sigUtils = new SigUtils();
        uint256 privateKey = 0xB0B;
        address wallet = vm.addr(privateKey);
        vm.prank(wallet);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        ISupa walletSupa = userWallet.supa();

        address walletOwner = supa.getWalletOwner(address(userWallet));

        Execution[] memory calls = new Execution[](0);
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;

        bytes32 digest = sigUtils.getTypedDataHash(address(userWallet), calls, nonce, deadline);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        address recovered = ecrecover(digest, v, r, s);

        WalletLogic(address(userWallet)).executeSignedBatch(calls, nonce, deadline, signature);
    }

    function testExecuteSignedBatchReplay() public {
        SigUtils sigUtils = new SigUtils();
        uint256 userPrivateKey = 0xB0B;
        address user = vm.addr(userPrivateKey);
        vm.startPrank(user);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        WalletProxy userWallet2 = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        Execution[] memory calls = new Execution[](0);
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;

        bytes32 digest = sigUtils.getTypedDataHash(address(userWallet), calls, nonce, deadline);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        WalletLogic(address(userWallet)).executeSignedBatch(calls, nonce, deadline, signature);
        vm.expectRevert(Errors.InvalidSignature.selector);
        WalletLogic(address(userWallet2)).executeSignedBatch(calls, nonce, deadline, signature);
        vm.stopPrank();
    }

    function testTransferAndCall2ToProxy() public {
        // TODO
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
        string memory VERSION = proxyLogic.VERSION();
        if (keccak256(abi.encodePacked(invalidVersionName)) == keccak256(abi.encodePacked(VERSION))) {
            invalidVersionName = "1.0.0-invalid";
        }
        vm.expectRevert();
        _upgradeWalletImplementation(invalidVersionName);
    }

    function testUpgradeDeprecatedVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        vm.prank(governance);
        versionManager.updateVersion(versionName, IVersionManager.Status.DEPRECATED, IVersionManager.BugLevel.NONE);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeLowBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        vm.prank(governance);
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.LOW);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeMedBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        vm.prank(governance);
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.MEDIUM);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeHighBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        vm.prank(governance);
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.HIGH);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testUpgradeCriticalBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        vm.prank(governance);
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.CRITICAL);
        vm.expectRevert();
        _upgradeWalletImplementation(versionName);
    }

    function testProposeTransferWalletOwnership(address newOwner) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(supa),
            callData: abi.encodeWithSignature("proposeTransferWalletOwnership(address)", newOwner),
            value: 0
        });
        userWallet.executeBatch(calls);
        address proposedOwner = SupaConfig(address(supa)).walletProposedNewOwner(address(userWallet));
        assert(proposedOwner == newOwner);
    }

    function testExecuteTransferWalletOwnership(address newOwner) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(supa),
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
        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(supa),
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
