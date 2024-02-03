// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm, VmSafe} from "forge-std/Vm.sol";

import {IPermit2} from "src/external/interfaces/IPermit2.sol";
import {TransferAndCall2} from "src/supa/TransferAndCall2.sol";
import {TestERC20} from "src/testing/TestERC20.sol";
import {TestNFT} from "src/testing/TestNFT.sol";
import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {MockNFTOracle} from "src/testing/MockNFTOracle.sol";
import {Supa} from "src/supa/Supa.sol";
import {ISupa } from "src/interfaces/ISupa.sol";
import {MigrationSupa} from "src/testing/MigrationSupa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {SupaState} from "src/supa/SupaState.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {WalletLogic, LinkedExecution, ReturnDataLink} from "src/wallet/WalletLogic.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {Execution, ExecutionLib} from "src/lib/Call.sol";
import {ITransferReceiver2} from "src/interfaces/ITransferReceiver2.sol";

import {SigUtils, ECDSA} from "test/utils/SigUtils.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Errors} from "src/libraries/Errors.sol";

contract WalletMigrationTest is Test {
    IPermit2 public permit2;
    TransferAndCall2 public transferAndCall2;

    TestNFT public nft;
    TestNFT public unregisteredNFT;

    MockNFTOracle public nftOracle;

    Supa public supa;
    MigrationSupa public newSupa;
    SupaConfig public supaConfig;
    SupaConfig public newSupaConfig;
    VersionManager public versionManager;
    WalletLogic public proxyLogic;

    address public user;
    WalletProxy public treasuryWallet;
    WalletProxy public userWallet;

    // Create 2 tokens
    TestERC20 public token0;
    TestERC20 public token1;

    MockERC20Oracle public token0Oracle;
    MockERC20Oracle public token1Oracle;

    bytes32 public constant FS_SALT = bytes32(0x1234567890123456789012345678901234567890123456789012345678901234);

    uint256 public mainnetFork;
    uint256 public goerliFork;

    // todo: test if old supa implementation needs to be aware of migration to prevent attacks

    function setUp() public {
        address owner = address(this);
        user = address(this);

        // deploy Supa contracts
        versionManager = new VersionManager(owner);
        supaConfig = new SupaConfig(owner);
        supa = new Supa(address(supaConfig), address(versionManager));
        newSupaConfig = new SupaConfig(owner);
        newSupa = new MigrationSupa(address(newSupaConfig), address(versionManager));
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

        ISupaConfig(address(newSupa)).setConfig(
            ISupaConfig.Config({
                treasuryWallet: address(0),
                treasuryInterestFraction: 0,
                maxSolvencyCheckGasCost: 10_000_000,
                liqFraction: 0.8 ether,
                fractionalReserveLeverage: 10
            })
        );

        ISupaConfig(address(newSupa)).setTokenStorageConfig(
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

        ISupaConfig(address(newSupa)).addERC20Info(
            address(token0),
            "token0",
            "t0",
            18,
            address(token0Oracle),
            0, // baseRate
            5, // slope1
            480, // slope2
            0.8 ether // targetUtilization
        );
        ISupaConfig(address(newSupa)).addERC20Info(
            address(token1),
            "token1",
            "t1",
            18,
            address(token1Oracle),
            0, // baseRate
            5, // slope1
            480, // slope2
            0.8 ether // targetUtilization
        );
    }

    //0xc7183455a4c133AE270771860664B6b7Ec320B01
    //0xc7183455a4C133Ae270771860664b6B7ec320bB1

    function test_walletMigration_DepositERC20(uint96 _amount0, uint96 _amount1) public {
        vm.startPrank(user);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        console.log("newSupa:", address(newSupa));
        console.log("userWallet.supa():", address(userWallet.supa()));
        _mintTokens(address(userWallet), _amount0, _amount1);

        // construct calls
        Execution[] memory calls = new Execution[](4);

        // set token allowances
        calls[0] = (
            Execution({
                target: address(token0),
                callData: abi.encodeWithSignature("approve(address,uint256)", address(newSupa), _amount0),
                value: 0
            })
        );

        calls[1] = (
            Execution({
                target: address(token1),
                callData: abi.encodeWithSignature("approve(address,uint256)", address(newSupa), _amount1),
                value: 0
            })
        );

        // deposit erc20 tokens
        calls[2] = (
            Execution({
                target: address(newSupa),
                callData: abi.encodeWithSignature("depositERC20(address,uint256)", token0, uint256(_amount0)),
                value: 0
            })
        );

        calls[3] = (
            Execution({
                target: address(newSupa),
                callData: abi.encodeWithSignature("depositERC20(address,uint256)", token1, uint256(_amount1)),
                value: 0
            })
        );

        // execute batch
        WalletLogic(address(userWallet)).executeBatch(calls);
        vm.stopPrank();
    }

    function testExecuteBatchLinkTransfer() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
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
                target: address(newSupa),
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
        vm.startPrank(wallet);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));

        address walletOwner = supa.getWalletOwner(address(userWallet));

        Execution[] memory calls = new Execution[](0);
        uint256 nonce = 0;
        uint256 deadline = type(uint256).max;

        bytes32 digest = sigUtils.getTypedDataHash(address(userWallet), calls, nonce, deadline);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        address recovered = ecrecover(digest, v, r, s);

        assertEq(recovered, walletOwner);

        WalletLogic(address(userWallet)).executeSignedBatch(calls, nonce, deadline, signature);
        vm.stopPrank();
    }

    function testExecuteSignedBatchReplay() public {
        SigUtils sigUtils = new SigUtils();
        uint256 userPrivateKey = 0xB0B;
        user = vm.addr(userPrivateKey);
        vm.startPrank(user);
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
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

    function testUpgradeVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        _upgradeWalletImplementation(userWallet, versionName);
    }

    function testUpgradeInvalidVersion(string memory invalidVersionName) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        string memory VERSION = proxyLogic.VERSION();
        if (keccak256(abi.encodePacked(invalidVersionName)) == keccak256(abi.encodePacked(VERSION))) {
            invalidVersionName = "1.0.0-invalid";
        }
        vm.expectRevert();
        _upgradeWalletImplementation(userWallet, invalidVersionName);
    }

    function testUpgradeDeprecatedVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.DEPRECATED, IVersionManager.BugLevel.NONE);
        vm.expectRevert();
        _upgradeWalletImplementation(userWallet, versionName);
    }

    function testUpgradeLowBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.LOW);
        vm.expectRevert();
        _upgradeWalletImplementation(userWallet, versionName);
    }

    function testUpgradeMedBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.MEDIUM);
        vm.expectRevert();
        _upgradeWalletImplementation(userWallet, versionName);
    }

    function testUpgradeHighBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.HIGH);
        vm.expectRevert();
        _upgradeWalletImplementation(userWallet, versionName);
    }

    function testUpgradeCriticalBugVersion() public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        (string memory versionName,,,,) = versionManager.getRecommendedVersion();
        versionManager.updateVersion(versionName, IVersionManager.Status.PRODUCTION, IVersionManager.BugLevel.CRITICAL);
        vm.expectRevert();
        _upgradeWalletImplementation(userWallet, versionName);
    }

    function testProposeTransferWalletOwnership(address newOwner) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(newSupa),
            callData: abi.encodeWithSignature("proposeTransferWalletOwnership(address)", newOwner),
            value: 0
        });
        userWallet.executeBatch(calls);
        address proposedOwner = SupaConfig(address(newSupa)).walletProposedNewOwner(address(userWallet));
        assert(proposedOwner == newOwner);
    }

    function testExecuteTransferWalletOwnership(address newOwner) public {
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));
        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(newSupa),
            callData: abi.encodeWithSignature("proposeTransferWalletOwnership(address)", newOwner),
            value: 0
        });
        userWallet.executeBatch(calls);

        vm.prank(newOwner);
        ISupa(address(newSupa)).executeTransferWalletOwnership(address(userWallet));

        address actualOwner = ISupa(address(newSupa)).getWalletOwner(address(userWallet));
        assert(actualOwner == newOwner);
    }

    function testExecuteInvalidOwnershipTransfer(address newOwner) public {
        vm.assume(newOwner != address(0));
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
        userWallet.updateSupa(address(newSupa));

        vm.prank(newOwner);
        vm.expectRevert();
        ISupa(address(supa)).executeTransferWalletOwnership(address(userWallet));
    }

    function testDeterministicWalletAddress() public {
        bytes32 salt = bytes32(0x1234567890123456789012345678901234567890123456789012345678901234);
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        VersionManager mainnetVersionManager = new VersionManager{salt: salt}(address(this));
        SupaConfig mainnetSupaConfig = new SupaConfig{salt: salt}(address(this));
        Supa mainnetSupa = new Supa{salt: salt}(address(mainnetSupaConfig), address(mainnetVersionManager));
        WalletLogic mainnetProxyLogic = new WalletLogic{salt: salt}();
        string memory VERSION = mainnetProxyLogic.VERSION();
        mainnetVersionManager.addVersion(IVersionManager.Status.PRODUCTION, address(mainnetProxyLogic));
        mainnetVersionManager.markRecommendedVersion(VERSION);

        uint256 nonce = SupaState(address(mainnetSupa)).walletNonce(address(this));
        assertEq(nonce, 0);
        address mainnetWallet1 = ISupaConfig(address(mainnetSupa)).createWallet();
        address mainnetWallet2 = ISupaConfig(address(mainnetSupa)).createWallet();
        address mainnetWallet3 = ISupaConfig(address(mainnetSupa)).createWallet();
        nonce = SupaState(address(mainnetSupa)).walletNonce(address(this));
        assertEq(nonce, 3);

        // todo: change to arbitrum
        string memory GOERLI_RPC_URL = vm.envString("GOERLI_RPC_URL");
        goerliFork = vm.createFork(GOERLI_RPC_URL);
        vm.selectFork(goerliFork);

        VersionManager goerliVersionManager = new VersionManager{salt: salt}(address(this));
        SupaConfig goerliSupaConfig = new SupaConfig{salt: salt}(address(this));
        Supa goerliSupa = new Supa{salt: salt}(address(goerliSupaConfig), address(goerliVersionManager));
        WalletLogic goerliProxyLogic = new WalletLogic{salt: salt}();
        goerliVersionManager.addVersion(IVersionManager.Status.PRODUCTION, address(goerliProxyLogic));
        goerliVersionManager.markRecommendedVersion(VERSION);

        nonce = SupaState(address(goerliSupa)).walletNonce(address(this));
        assertEq(nonce, 0);
        address goerliWallet1 = ISupaConfig(address(goerliSupa)).createWallet();
        address goerliWallet2 = ISupaConfig(address(goerliSupa)).createWallet();
        address goerliWallet3 = ISupaConfig(address(goerliSupa)).createWallet();
        nonce = SupaState(address(goerliSupa)).walletNonce(address(this));
        assertEq(nonce, 3);

        assertEq(address(mainnetSupa), address(goerliSupa));
        assertEq(mainnetWallet1, goerliWallet1);
        assertEq(mainnetWallet2, goerliWallet2);
        assertEq(mainnetWallet3, goerliWallet3);
    }

    function _upgradeWalletImplementation(WalletProxy _userWallet, string memory versionName) internal {
        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(newSupa),
            callData: abi.encodeWithSignature("upgradeWalletImplementation(string)", versionName),
            value: 0
        });
        _userWallet.executeBatch(calls);
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

    function _mintTokens(address to, uint256 amount0, uint256 amount1) internal {
        token0.mint(to, amount0);
        token1.mint(to, amount1);
    }
}
