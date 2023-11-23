// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { TaskCreator } from "src/gelato/TaskCreator.sol";

contract DepositFunds1Balance is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        vm.startBroadcast(owner);
        TaskCreator taskCreator = TaskCreator(0x459ba2a63cB8E306555b563236b4d1f23B047122);
        taskCreator.depositFunds1Balance{value: 0.05 ether}(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 0.05 ether);
        vm.stopBroadcast();
    }
}

// forge script script/utils/DepositFunds1Balance.s.sol:DepositFunds1Balance --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
