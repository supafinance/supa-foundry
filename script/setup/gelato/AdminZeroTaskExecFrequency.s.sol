// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract AdminZeroTaskExecFrequency is Script {
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

        address user = 0x8E292FE20ee2BDf29B4BC7c104641b59eAEFf457;

        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.adminZeroTaskExecFrequency(user);
        vm.stopBroadcast();
    }
}

// forge script script/setup/gelato/AdminZeroTaskExecFrequency.s.sol:AdminZeroTaskExecFrequency --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
// forge script script/setup/gelato/AdminZeroTaskExecFrequency.s.sol:AdminZeroTaskExecFrequency --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer