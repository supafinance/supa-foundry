// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator, ITaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

/// @notice Deploys {TaskCreator}
contract SetupTaskCreator is BaseScript {
    function run() public virtual {
        uint256 chainId = block.chainid;

        address deployer;
        address usdc;
        address feeCollector;
        address gasPriceFeed;
        uint256 powerCreditRate;
        uint256 depositAmount;
        uint256 powerPerExecution = 0.0005 ether; // 2000 runs per credit
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            usdc = vm.envAddress("USDC_GOERLI");
            feeCollector = vm.envAddress("AUTOMATION_FEE_COLLECTOR_GOERLI");
            gasPriceFeed = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
            powerCreditRate = 1e6; // 1 usdc
            depositAmount = 0.001 ether * 60;
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            usdc = vm.envAddress("USDC_ARBITRUM");
            feeCollector = vm.envAddress("AUTOMATION_FEE_COLLECTOR_ARBITRUM");
            gasPriceFeed = vm.envAddress("GAS_PRICE_FEED_ARBITRUM");
            powerCreditRate = 1e6; // 1 usdc
            depositAmount = 5 ether; // 5 power credits
        } else if (chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
            usdc = vm.envAddress("USDC_BASE");
            feeCollector = vm.envAddress("AUTOMATION_FEE_COLLECTOR_BASE");
            gasPriceFeed = vm.envAddress("GAS_PRICE_FEED_BASE");
            powerCreditRate = 1e6; // 1 usdc
            depositAmount = 5 ether; // 5 power credits
        } else {
            revert("unsupported chain");
        }

        address supa = vm.envAddress("SUPA_ADDRESS");
        address automate = vm.envAddress("AUTOMATE");
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
        address allowlistServer = vm.envAddress("GELATO_SERVER");
        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);

        taskCreator.addAllowlistRole(allowlistServer);
        taskCreator.setFeeCollector(feeCollector);
        taskCreator.setGasPriceFeed(gasPriceFeed);
        ITaskCreator.Tier[] memory tiers = new ITaskCreator.Tier[](1);
        tiers[0] = ITaskCreator.Tier({
            limit: 0,
            rate: powerCreditRate
        });
        taskCreator.setTiers(tiers);
        taskCreator.setDepositAmount(depositAmount);
        taskCreator.setPowerPerExecution(powerPerExecution);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/SetupTaskCreator.s.sol:SetupTaskCreator --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/deploy/gelato/SetupTaskCreator.s.sol:SetupTaskCreator --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer -g 100 --etherscan-api-key $ARBISCAN_API_KEY
// forge script script/deploy/gelato/SetupTaskCreator.s.sol:SetupTaskCreator --rpc-url $BASE_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY
