// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract SetPowerPerExecution is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address deployer;
        uint256 powerPerExecution;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            powerPerExecution = 0.001 ether;
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            powerPerExecution = 0.001 ether; // todo
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setPowerPerExecution(powerPerExecution);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetPowerPerExecution.s.sol:SetPowerPerExecution --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
