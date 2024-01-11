// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator, ITaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

/// @notice Deploys {TaskCreator}
contract DeployTaskCreator is BaseScript {
    function run() public virtual {
        uint256 chainId = block.chainid;

        address deployer;
        address usdc;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            usdc = vm.envAddress("USDC_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            usdc = vm.envAddress("USDC_ARBITRUM");
        } else {
            revert("unsupported chain");
        }

        address supa = vm.envAddress("SUPA_ADDRESS");
        address automate = vm.envAddress("AUTOMATE");
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
        vm.startBroadcast(deployer);
        TaskCreator taskCreator = new TaskCreator(supa, automate, taskCreatorProxyAddress, usdc);
        TaskCreatorProxy taskCreatorProxy = TaskCreatorProxy(taskCreatorProxyAddress);
        taskCreatorProxy.upgrade(address(taskCreator));
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/DeployTaskCreator.s.sol:DeployTaskCreator --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
// forge script script/deploy/gelato/DeployTaskCreator.s.sol:DeployTaskCreator --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer -g 70


// forge create src/gelato/TaskCreator.sol:TaskCreator --rpc-url $ARBITRUM_RPC_URL --etherscan-api-key $ARBISCAN_API_KEY --constructor-args $SUPA_ADDRESS $AUTOMATE $TASK_CREATOR_PROXY_ADDRESS $USDC_ARBITRUM --account supa_deployer
