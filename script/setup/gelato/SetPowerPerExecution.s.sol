// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract SetPowerPerExecution is Script {
    function run() public virtual {
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address owner = 0xc9B6088732E83ef013873e2f04d032F1a7a2E42D;

        vm.startBroadcast(owner);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setPowerPerExecution(0.001 ether);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetPowerPerExecution.s.sol:SetPowerPerExecution --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
