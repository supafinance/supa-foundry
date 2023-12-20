// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract AddAllowlistRole is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));

        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }

        address gelatoServer = vm.envAddress("GELATO_SERVER");
        address addressToAllowlist = deployer;

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.addAllowlistRole(addressToAllowlist);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/AddAllowlistRole.s.sol:AddAllowlistRole --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer

// forge script script/setup/gelato/AddAllowlistRole.s.sol:AddAllowlistRole --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer
