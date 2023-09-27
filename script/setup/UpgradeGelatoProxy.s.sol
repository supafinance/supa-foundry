// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";
import {TaskCreatorLogic} from "src/gelato/TaskCreatorLogic.sol";

contract UpgradeGelatoProxy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address automate = vm.envAddress("AUTOMATE");
        address supa = vm.envAddress("SUPA");

        vm.startBroadcast(deployerPrivateKey);
        TaskCreatorProxy taskCreatorProxy = TaskCreatorProxy(taskCreatorProxyAddress);
        TaskCreatorLogic taskCreatorLogic = new TaskCreatorLogic(supa, automate, address(taskCreatorProxy));
        taskCreatorProxy.upgrade(address(taskCreatorLogic));
        vm.stopBroadcast();
    }
}

// forge script script/setup/UpgradeGelatoProxy.s.sol:UpgradeGelatoProxy --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
