// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract SetDepositAmount is Script {
    function run() public virtual {
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address owner = 0xc9B6088732E83ef013873e2f04d032F1a7a2E42D;

        vm.startBroadcast(owner);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setDepositAmount(0.001 ether * 60);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetDepositAmount.s.sol:SetDepositAmount --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
