// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract CalculateUsdcForPower is Script {
    function run() public virtual {
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        uint256 usdcForPower = taskCreator.calculateUsdcForPower(15 ether);
        console.log(usdcForPower);
    }
}

// forge script script/data/gelato/CalculateUsdcForPower.s.sol:CalculateUsdcForPower --rpc-url $GOERLI_RPC_URL -vvvv

// forge script script/data/gelato/CalculateUsdcForPower.s.sol:CalculateUsdcForPower --rpc-url $ARBITRUM_RPC_URL -vvvv