// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, Vm, console} from "forge-std/Test.sol";

import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {TaskCreator, ITaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorErrors} from "src/gelato/interfaces/ITaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";
import {Supa, IERC20} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic, LinkedCall, ReturnDataLink} from "src/wallet/WalletLogic.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";

import {Call} from "src/lib/Call.sol";

contract GelatoArbitrumTest is Test {
    GelatoOperator public gelatoOperator;
    WalletProxy public walletProxy;
    TaskCreatorProxy public taskCreatorProxy;
    address public automate = 0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0;
    address public usdc = vm.envAddress("USDC_ARBITRUM");
    VersionManager public versionManager;
    SupaConfig public supaConfig;
    Supa public supa;

    WalletLogic public proxyLogic;
    WalletProxy public userWallet;

    uint256 private arbitrumFork;
    string private ARBITRUM_RPC_URL = vm.envString("ARBITRUM_RPC_URL");

    address dedicatedSender = vm.envAddress("GELATO_DEDICATED_SENDER");
    address owner = vm.envAddress("DEPLOYER");

    function setUp() public {
        // fork arbitrum
        arbitrumFork = vm.createFork(ARBITRUM_RPC_URL);
        vm.selectFork(arbitrumFork);

        gelatoOperator = GelatoOperator(vm.envAddress("GELATO_OPERATOR_ADDRESS"));

        versionManager = VersionManager(vm.envAddress("VERSION_MANAGER_ADDRESS"));
        supaConfig = SupaConfig(vm.envAddress("SUPA_CONFIG_ADDRESS"));
        supa = Supa(payable(vm.envAddress("SUPA_ADDRESS")));

        taskCreatorProxy = TaskCreatorProxy(payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS")));
    }

    // function testAddOperator() public {
    //     address target = address(this);
    //     walletProxy.addOperator(target);
    // }

    function testFeeCollectorAddress() public {
        address feeCollector = address(TaskCreator(address(taskCreatorProxy)).feeCollector());
        assertEq(feeCollector, vm.envAddress("AUTOMATION_FEE_COLLECTOR_ARBITRUM"));
    }

    function testTiers() public {
        ITaskCreator.Tier[] memory tiers = TaskCreator(address(taskCreatorProxy)).getAllTiers();
        assertEq(tiers.length, 1);
        assertEq(tiers[0].limit, 0);
        assertEq(tiers[0].rate, vm.envUint("POWER_CREDIT_RATE"));
    }

    function testSupaAddress() public {
        address supaAddress = address(TaskCreator(address(taskCreatorProxy)).supa());
        assertEq(supaAddress, vm.envAddress("SUPA_ADDRESS"));
    }

    function testUsdcAddress() public {
        address usdcAddress = address(TaskCreator(address(taskCreatorProxy)).usdc());
        assertEq(usdcAddress, vm.envAddress("USDC_ARBITRUM"));
    }

    function testDepositAmount() public {
        uint256 depositAmount = TaskCreator(address(taskCreatorProxy)).depositAmount();
        assertEq(depositAmount, vm.envUint("DEPOSIT_AMOUNT"));
    }

    function testPowerPerExecution() public {
        uint256 powerPerExecution = TaskCreator(address(taskCreatorProxy)).powerPerExecution();
        assertEq(powerPerExecution, vm.envUint("POWER_PER_EXECUTION"));
    }

    function testTaskExecFrequency() public {
        bytes32 taskId = bytes32(0x0ee4060fe2599a85471c204981105d466e91c93796d8c606e66f5449dc6835b9);
        address taskOwner = TaskCreator(address(taskCreatorProxy)).taskOwner(taskId);
        assert(taskOwner != address(0));
        uint256 taskExecFrequency = TaskCreator(address(taskCreatorProxy)).taskExecFrequency(taskId);
        console.log(taskExecFrequency);
        uint256 expected = uint256(uint256(1 ether) / uint256(uint256(60) * uint256(1_000))) * uint256(1_000);
        console.log(expected);
        assertEq(taskExecFrequency, expected);
    }

    function testTaskDepositAmount() public {
        bytes32 taskId = bytes32(0x0ee4060fe2599a85471c204981105d466e91c93796d8c606e66f5449dc6835b9);
        address taskOwner = TaskCreator(address(taskCreatorProxy)).taskOwner(taskId);
        assert(taskOwner != address(0));
        uint256 taskDepositAmount = TaskCreator(address(taskCreatorProxy)).depositAmounts(taskId);
        console.log(taskDepositAmount);
        assertEq(taskDepositAmount, vm.envUint("DEPOSIT_AMOUNT"));
    }

    function testGasPriceFeedAddress() public {
        address gasPriceFeed = address(TaskCreator(address(taskCreatorProxy)).gasPriceFeed());
        assertEq(gasPriceFeed, vm.envAddress("GAS_PRICE_FEED_ARBITRUM"));
    }

    function testDedicatedSender() public {
        address dedicatedSender = address(this);
        assertEq(gelatoOperator.dedicatedSender(), dedicatedSender);
    }

    function testProxy() public {
        TaskCreator taskCreator = new TaskCreator(address(supa), address(automate), address(taskCreatorProxy), usdc);
        vm.prank(owner);
        taskCreatorProxy.upgrade(address(taskCreator));

        assertEq(taskCreatorProxy.implementation(), address(taskCreator));
    }

    function testAddAllowlistRole() public {
        vm.prank(owner);
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
        vm.startPrank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        assert(TaskCreator(address(taskCreatorProxy)).allowlistRole(address(this)));
        TaskCreator(address(taskCreatorProxy)).removeAllowlistRole(address(this));
        assert(!TaskCreator(address(taskCreatorProxy)).allowlistRole(address(this)));
        vm.stopPrank();
    }

    function testAddAllowListCidWithoutRole() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        vm.startPrank(owner);
        vm.expectRevert(TaskCreatorErrors.Unauthorized.selector);
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        vm.stopPrank();
    }

    function testAddAllowListCid() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        vm.startPrank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        assert(TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));
        vm.stopPrank();
    }

    function testRemoveAllowlistCidWithoutRole() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        vm.startPrank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        vm.stopPrank();
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        assert(TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));

        vm.startPrank(address(1));
        vm.expectRevert(TaskCreatorErrors.Unauthorized.selector);
        TaskCreator(address(taskCreatorProxy)).removeAllowlistCid(cid);
        vm.stopPrank();
    }

    function testRemoveAllowlistCid() public {
        string memory cid = "QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk";

        vm.startPrank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        vm.startPrank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        assert(TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));

        TaskCreator(address(taskCreatorProxy)).removeAllowlistCid(cid);
        assert(!TaskCreator(address(taskCreatorProxy)).allowlistCid(cid));
    }

    function testSetDepositAmount() public {
        vm.prank(owner);
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
        vm.prank(owner);
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

        Call[] memory calls = new Call[](1);
        calls[0] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
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

        Call[] memory calls = new Call[](3);
        calls[0] = Call({
            to: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("purchasePowerExactUsdc(address,uint256)", msg.sender, 1 ether),
            value: 0
        });
        calls[2] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
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
        vm.prank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(admin);
        string memory newCid = "QmPmKTEBA39PPVu8LVgAgXdj3rUUQv2WUZ92X6woDF154q";
        bytes memory signature = hex"4fe283a2e7984beda941908f1ae4fee87556ee4669318d0226bc7202d9eda5d15ff308f053da8bd431ea059cfba0e8866942c69274a899e83f0aff572c5116e41c";

        Call[] memory calls = new Call[](3);
        calls[0] = Call({
            to: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("purchasePowerExactUsdc(address,uint256)", msg.sender, 1 ether),
            value: 0
        });
        calls[2] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool,address,bytes)", 0, address(1), newCid, 1000, false, admin, signature),
            value: 0
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

        LinkedCall[] memory linkedCalls = new LinkedCall[](3);
        ReturnDataLink[] memory links = new ReturnDataLink[](1);
        links[0] = ReturnDataLink({
            returnValueOffset: 0,
            isStatic: true,
            callIndex: 1,
            offset: 4
        });
        linkedCalls[0] = LinkedCall({
        call: Call({
            to: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[1] = LinkedCall({
        call: Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        }),
            links: new ReturnDataLink[](0)
        });
        linkedCalls[2] = LinkedCall({
            call: Call({
                to: address(taskCreatorProxy),
                callData: abi.encodeWithSignature("cancelTask(bytes32)", 0),
                value: 0
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

        Call[] memory calls = new Call[](2);
        calls[0] = Call({
            to: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        });

        vm.recordLogs();
        userWallet.executeBatch(calls);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log(entries.length);

        bytes32 taskId = entries[entries.length - 1].topics[1];

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

        Call[] memory calls = new Call[](2);
        calls[0] = Call({
            to: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        });

        vm.recordLogs();
        userWallet.executeBatch(calls);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 taskId = entries[entries.length - 1].topics[1];

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

        Call[] memory calls = new Call[](2);
        calls[0] = Call({
            to: address(usdc),
            callData: abi.encodeWithSignature("approve(address,uint256)", address(taskCreatorProxy), type(uint256).max),
            value: 0
        });
        calls[1] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,address,string,uint256,bool)", 0, address(1), cid, 1000, false),
            value: 0
        });

        vm.recordLogs();
        userWallet.executeBatch(calls);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 taskId = entries[entries.length - 1].topics[1];

        vm.startPrank(address(1));
        vm.expectRevert(TaskCreatorErrors.NotTaskOwner.selector);
        TaskCreator(address(taskCreatorProxy)).cancelTask(taskId);
        vm.stopPrank();
    }

    function _setupTaskCreator(string memory cid) internal {
        vm.startPrank(owner);
        TaskCreator(address(taskCreatorProxy)).addAllowlistRole(address(this));
        TaskCreator(address(taskCreatorProxy)).addAllowlistCid(cid);
        TaskCreator(address(taskCreatorProxy)).setDepositAmount(1 ether);
        TaskCreator(address(taskCreatorProxy)).setPowerPerExecution(1 ether);
        TaskCreator(address(taskCreatorProxy)).setFeeCollector(address(1));
        vm.stopPrank();

    }
}
