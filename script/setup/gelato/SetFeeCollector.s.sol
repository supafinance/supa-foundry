// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract SetFeeCollector is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));

        address deployer;
        address feeCollector;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            feeCollector = vm.envAddress("GAS_PRICE_FEED_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            feeCollector = vm.envAddress("GAS_PRICE_FEED_ARBITRUM");
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setFeeCollector(feeCollector);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetFeeCollector.s.sol:SetFeeCollector --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
