// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract GetUserPowerData is Script {
    function run() public virtual {
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address owner = 0xc9B6088732E83ef013873e2f04d032F1a7a2E42D;
        address user = 0x4141EC9F8Acfd636E7b037EB3171f4452656dA35;

        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        (uint256 lastUpdate, uint256 taskExecsPerSecond) = taskCreator.userPowerData(user);
        console.log(block.timestamp);
        console.log(lastUpdate);
        console.log(block.timestamp - lastUpdate);
        console.log(taskExecsPerSecond);
        console.log((block.timestamp - lastUpdate) * taskExecsPerSecond);
        uint256 powerPerExecution = taskCreator.powerPerExecution();
        console.log(powerPerExecution);
        console.log((block.timestamp - lastUpdate) * taskExecsPerSecond * powerPerExecution);
        console.log((block.timestamp - lastUpdate) * taskExecsPerSecond * powerPerExecution / 1 ether);
        uint256 balance = taskCreator.balanceOf(user);
        console.log(balance);
        address feeCollector = taskCreator.feeCollector();
        console.log(feeCollector);
    }
}

// forge script script/data/gelato/GetUserPowerData.s.sol:GetUserPowerData --rpc-url $GOERLI_RPC_URL -vvvv
