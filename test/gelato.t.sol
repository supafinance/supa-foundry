// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, Vm} from "forge-std/Test.sol";

import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorErrors} from "src/gelato/interfaces/ITaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";
import {Supa, IERC20} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic, LinkedExecution, ReturnDataLink} from "src/wallet/WalletLogic.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";

import {Execution} from "src/lib/Call.sol";

contract GelatoTest is Test {
    GelatoOperator public gelatoOperator;
    WalletProxy public walletProxy;
    TaskCreator public taskCreator;
    TaskCreatorProxy public taskCreatorProxy;
    address public automate = 0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0;
    address public usdc = vm.envAddress("USDC_MAINNET");
    VersionManager public versionManager;
    SupaConfig public supaConfig;
    Supa public supa;

    WalletLogic public proxyLogic;
    WalletProxy public userWallet;

    uint256 private mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");


    function setUp() public {
        // fork mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        address dedicatedSender = address(this);
        address owner = address(this);
        gelatoOperator = new GelatoOperator(dedicatedSender);

        versionManager = new VersionManager(owner);
        supaConfig = new SupaConfig(owner);
        supa = new Supa(address(supaConfig), address(versionManager));
        proxyLogic = new WalletLogic();

        ISupaConfig(address(supa)).setConfig(
            ISupaConfig.Config({
                treasuryWallet: address(0),
                treasuryInterestFraction: 0,
                maxSolvencyCheckGasCost: 10_000_000,
                liqFraction: 8e17,
                fractionalReserveLeverage: 10
            })
        );

        string memory version = proxyLogic.VERSION();

        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(proxyLogic));
        versionManager.markRecommendedVersion(version);

        taskCreatorProxy = new TaskCreatorProxy();
        taskCreator = new TaskCreator(address(supa), address(automate), address(taskCreatorProxy), address(usdc));
        taskCreatorProxy.upgrade(address(taskCreator));
    }

    // function testAddOperator() public {
    //     address target = address(this);
    //     walletProxy.addOperator(target);
    // }

    function testDedicatedSender() public {
        address dedicatedSender = address(this);
        assertEq(gelatoOperator.dedicatedSender(), dedicatedSender);
    }

    function testProxy() public {
        taskCreatorProxy = new TaskCreatorProxy();
        taskCreator = new TaskCreator(address(supa), address(automate), address(taskCreatorProxy), usdc);

        taskCreatorProxy.upgrade(address(taskCreator));

        assertEq(taskCreatorProxy.implementation(), address(taskCreator));
    }

    function testAddAllowlistRole() public {
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        assert(TaskCreator(address(taskCreatorProxy)).allowlistRole(address(this)));
    }

    function testAddAllowlistRole_NotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        vm.stopPrank();
    }

    function testRemoveAllowlistRole() public {
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        assert(TaskCreator(address(taskCreatorProxy)).allowlistRole(address(this)));
        TaskCreator(address(taskCreatorProxy)).removeAllowlistRole(address(this));
        assert(!TaskCreator(address(taskCreatorProxy)).allowlistRole(address(this)));
    }

    function testAddAllowListCidWithoutRole() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        vm.expectRevert(TaskCreatorErrors.Unauthorized.selector);
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
    }

    function testAddAllowListCid() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        assert(TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));
    }

    function testRemoveAllowlistCidWithoutRole() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        assert(TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));

        vm.startPrank(address(1));
        vm.expectRevert(TaskCreatorErrors.Unauthorized.selector);
        TaskCreator(address(taskCreatorProxy)).removeAllowlistCid(cid);
        vm.stopPrank();
    }

    function testRemoveAllowlistCid() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        assert(TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));

        TaskCreator(address(taskCreatorProxy)).removeAllowlistCid(cid);
        assert(!TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));
    }

    function testSetDepositAmount() public {
        TaskCreator(address(taskCreatorProxy)).setDepositAmount(1 ether);
        assertEq(TaskCreator(address(taskCreatorProxy)).depositAmount(), 1 ether);
    }

    function testSetDepositAmount_NotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        TaskCreator(address(taskCreatorProxy)).setDepositAmount(1 ether);
        vm.stopPrank();
    }

    function testSetPowerPerExecution() public {
        TaskCreator(address(taskCreatorProxy)).setPowerPerExecution(1 ether);
        assertEq(TaskCreator(address(taskCreatorProxy)).powerPerExecution(), 1 ether);
    }

    function testSetPowerPerExecution_NotOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        TaskCreator(address(taskCreatorProxy)).setPowerPerExecution(1 ether);
        vm.stopPrank();
    }

    function testCreateTask_UnauthorizedCID() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(taskCreatorProxy),
            value: 0,
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false)
        });
        vm.expectRevert(abi.encodeWithSelector(TaskCreatorErrors.UnauthorizedCID.selector, cid));
        userWallet.executeBatch(calls);
    }

    function testCreateTask() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        _setupTaskCreator(cid);

        deal({
            token: address(usdc),
            to: address(userWallet),
            give: 1000 ether
        });

        Execution[] memory calls = new Execution[](3);
        calls[0] = Execution({
            target: address(usdc),
            value: 0,
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max)

        });
        calls[1] = Execution({
            target: address(taskCreatorProxy),
            value: 0,
            callData: abi.encodeWithSignature("purchasePowerExactUsdc(address,uint256)", msg.sender, 1 ether)
        });
        calls[2] = Execution({
            target: address(taskCreatorProxy),
            value: 0,
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false)
        });
        userWallet.executeBatch(calls);

        assertEq(IERC20(usdc).balanceOf(address(userWallet)), 999 ether);
        uint256 powerCreditAmount = TaskCreator(address(taskCreatorProxy)).calculatePowerPurchase(1 ether);
        assertEq(TaskCreator(address(taskCreatorProxy)).balanceOf(address(userWallet)), powerCreditAmount);
        address owner = supa.getWalletOwner(address(userWallet));
        (uint256 lastUpdate, uint256 taskExecsPerSecond) = TaskCreator(address(taskCreatorProxy)).userPowerData(owner);
        assert(lastUpdate > 0);
        assert(taskExecsPerSecond > 0);
    }

    function testCreateTaskWithSignature() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

//        cid: Qmb59c6n73Pd55D2m3MSY9QuVZ2fohZxTNrM8BB3Bgujpo
//        signature: 0xe99e88495568566f1ae21fa16cfe487c567fb1c05cb4b39677b79162930e88b1217145de3d553e7b021c266fda099e028e20123510f3917d29e8cba0e62c93ae1b

        _setupTaskCreator(cid);

        deal({
            token: address(usdc),
            to: address(userWallet),
            give: 1000 ether
        });

        address admin = address(0xDf048196C83A83eFE5A56fEd1A577b65388e09d0);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(admin);
        string memory newCid = "QmPmKTEBA39PPVu8LVgAgXdj3rUUQv2WUZ92X6woDF154q";
        bytes memory signature = hex"4fe283a2e7984beda941908f1ae4fee87556ee4669318d0226bc7202d9eda5d15ff308f053da8bd431ea059cfba0e8866942c69274a899e83f0aff572c5116e41c";

        Execution[] memory calls = new Execution[](3);
        calls[0] = Execution({
            target: address(usdc),
            value: 0,
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max)
        });
        calls[1] = Execution({
            target: address(taskCreatorProxy),
            value: 0,
            callData: abi.encodeWithSignature("purchasePowerExactUsdc(address,uint256)", msg.sender, 1 ether)
        });
        calls[2] = Execution({
            target: address(taskCreatorProxy),
            value: 0,
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool,address,bytes)", 0, address(1), newCid, 1000, false, admin, signature)
        });
        userWallet.executeBatch(calls);

        assertEq(IERC20(usdc).balanceOf(address(userWallet)), 999 ether);
        uint256 powerCreditAmount = TaskCreator(address(taskCreatorProxy)).calculatePowerPurchase(1 ether);
        assertEq(TaskCreator(address(taskCreatorProxy)).balanceOf(address(userWallet)), powerCreditAmount);
        address owner = supa.getWalletOwner(address(userWallet));
        (uint256 lastUpdate, uint256 taskExecsPerSecond) = TaskCreator(address(taskCreatorProxy)).userPowerData(owner);
        assert(lastUpdate > 0);
        assert(taskExecsPerSecond > 0);
    }

    function testCancelTask() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        _setupTaskCreator(cid);

        deal({
            token: address(usdc),
            to: address(userWallet),
            give: 1000 ether
        });

        LinkedExecution[] memory linkedCalls = new LinkedExecution[](3);
        ReturnDataLink[] memory links = new ReturnDataLink[](1);
        links[0] = ReturnDataLink({
            returnValueOffset: 0,
            isStatic: true,
            callIndex: 1,
            offset: 4
        });
        linkedCalls[0] = LinkedExecution({
        execution: Execution({
            target: address(usdc),
            value: 0,
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max)
        }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[1] = LinkedExecution({
        execution: Execution({
            target: address(taskCreatorProxy),
            value: 0,
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false)
        }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[2] = LinkedExecution({
            execution: Execution({
                target: address(taskCreatorProxy),
                value: 0,
                callData: abi.encodeWithSignature("cancelTask(bytes32)", 0)
            }),
            links: links
        });
        WalletLogic(address(userWallet)).executeBatchLink(linkedCalls);

        // todo: assert they received the deposit back
    }

    function testCancelSolventTask() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        _setupTaskCreator(cid);

        deal({
            token: address(usdc),
            to: address(userWallet),
            give: 1000 ether
        });

        Execution[] memory calls = new Execution[](2);
        calls[0] = Execution({
            target: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Execution({
            target: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        });

        vm.recordLogs();
        userWallet.executeBatch(calls);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 taskId = entries[6].topics[1];

        vm.expectRevert(abi.encodeWithSelector(TaskCreatorErrors.TaskNotInsolvent.selector, taskId));
        TaskCreator(address(taskCreatorProxy)).cancelInsolventTask(taskId);
    }

    function testCancelInsolventTask() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        _setupTaskCreator(cid);

        deal({
            token: address(usdc),
            to: address(userWallet),
            give: 1000 ether
        });

        Execution[] memory calls = new Execution[](2);
        calls[0] = Execution({
            target: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Execution({
            target: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        });

        vm.recordLogs();
        userWallet.executeBatch(calls);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 taskId = entries[6].topics[1];

        vm.warp(block.timestamp + 1 days);
        TaskCreator(address(taskCreatorProxy)).cancelInsolventTask(taskId);

        // todo: assert they received the deposit
    }

    function testCancelTask_NotOwner() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        _setupTaskCreator(cid);

        deal({
            token: address(usdc),
            to: address(userWallet),
            give: 1000 ether
        });

        Execution[] memory calls = new Execution[](2);
        calls[0] = Execution({
            target: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Execution({
            target: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        });

        vm.recordLogs();
        userWallet.executeBatch(calls);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 taskId = entries[6].topics[1];

        vm.startPrank(address(1));
        vm.expectRevert(TaskCreatorErrors.NotTaskOwner.selector);
        TaskCreator(address(taskCreatorProxy)).cancelTask(taskId);
        vm.stopPrank();
    }

    function _setupTaskCreator(string memory cid) internal {
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        TaskCreator(address(taskCreatorProxy)).setDepositAmount(1 ether);
        TaskCreator(address(taskCreatorProxy)).setPowerPerExecution(1 ether);
        TaskCreator(address(taskCreatorProxy)).setFeeCollector(address(1));

    }
}
