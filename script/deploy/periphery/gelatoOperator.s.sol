// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

contract DeployGelatoOperator is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address dedicatedSender = vm.envAddress("GELATO_DEDICATED_SENDER");
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }
        bytes32 salt = vm.envBytes32("GELATO_OPERATOR_SALT");
        vm.startBroadcast(deployer);
        GelatoOperator gelatoOperator = new GelatoOperator{salt: salt}(dedicatedSender);
        vm.stopBroadcast();
        assert(address(gelatoOperator) == vm.envAddress("GELATO_OPERATOR_ADDRESS"));
    }
}

// forge script script/deploy/periphery/gelatoOperator.s.sol:DeployGelatoOperator --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer

// forge script script/deploy/periphery/gelatoOperator.s.sol:DeployGelatoOperator --rpc-url $ARBITRUM_RPC_URL --broadcast -vvvv --account supa_deployer -g 100
