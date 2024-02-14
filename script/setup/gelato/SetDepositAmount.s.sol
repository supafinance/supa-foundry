// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract SetDepositAmount is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));

        address deployer;
        uint256 depositAmount;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            depositAmount = 0.001 ether * 60;
        } else if (chainId == 42161 || chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
            depositAmount = 0.001 ether * 60;
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setDepositAmount(depositAmount);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetDepositAmount.s.sol:SetDepositAmount --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer --etherscan-api-key $GOERLISCAN_API_KEY
// forge script script/setup/gelato/SetDepositAmount.s.sol:SetDepositAmount --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $ARBISCAN_API_KEY
// forge script script/setup/gelato/SetDepositAmount.s.sol:SetDepositAmount --rpc-url $BASE_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY
