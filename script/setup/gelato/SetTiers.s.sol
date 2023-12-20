// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator, ITaskCreator} from "src/gelato/TaskCreator.sol";

contract SetTiers is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));

        address deployer;
        ITaskCreator.Tier[] memory tiers = new ITaskCreator.Tier[](1);
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            tiers[0] = ITaskCreator.Tier({
                limit: 0,
                rate: 1e6
            });
        } else if (chainId == 42161) {
            revert("arbitrum parameters not set");
            deployer = vm.envAddress("DEPLOYER");
            tiers[0] = ITaskCreator.Tier({
                limit: 0,
                rate: 1e6
            });
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.setTiers(tiers);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/SetTiers.s.sol:SetTiers --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
