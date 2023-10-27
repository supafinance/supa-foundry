// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

/// @notice Deploys {TaskCreator}
contract DeployTaskCreator is BaseScript {
    function run() public virtual {
        address supa = vm.envAddress("SUPA");
        address automate = vm.envAddress("AUTOMATE");
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address owner = 0xc9B6088732E83ef013873e2f04d032F1a7a2E42D;
        vm.startBroadcast(owner);
        TaskCreator taskCreator = new TaskCreator(supa, automate, taskCreatorProxyAddress);
        TaskCreatorProxy taskCreatorProxy = TaskCreatorProxy(taskCreatorProxyAddress);
        taskCreatorProxy.upgrade(address(taskCreator));
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/DeployTaskCreator.s.sol:DeployTaskCreator --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
