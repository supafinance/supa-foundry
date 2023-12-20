// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract SetFeeCollector is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));

        address deployer;
        address gasPriceFeed;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            gasPriceFeed = vm.envAddress("AUTOMATION_FEE_COLLECTOR_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            gasPriceFeed = vm.envAddress("AUTOMATION_FEE_COLLECTOR_ARBITRUM");
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setGasPriceFeed(gasPriceFeed);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetFeeCollector.s.sol:SetFeeCollector --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
