// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract UpgradeGelatoProxy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address automate = vm.envAddress("AUTOMATE");
        address supa = vm.envAddress("SUPA");

        // todo: update depending on the network
        address usdc = vm.envAddress("USDC_GOERLI");

        vm.startBroadcast(deployerPrivateKey);
        TaskCreatorProxy taskCreatorProxy = TaskCreatorProxy(taskCreatorProxyAddress);
        TaskCreator taskCreator = new TaskCreator(supa, automate, address(taskCreatorProxy), usdc);
        taskCreatorProxy.upgrade(address(taskCreator));
        vm.stopBroadcast();
    }
}

// forge script script/setup/UpgradeGelatoProxy.s.sol:UpgradeGelatoProxy --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
