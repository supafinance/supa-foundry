// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ProxiedOperator} from "src/periphery/ProxiedOperator.sol";

contract DeployProxiedOperator is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address deployer;
        address dedicatedSender;
        address supaAdmin;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            revert("Add deployer and dedicatedSender");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            dedicatedSender = 0xFB850ffad5349F4c8457EA8909F12BA3d63578F8;
            supaAdmin = vm.envAddress("SUPA_ADMIN_ARBITRUM");
        } else if (chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
            dedicatedSender = 0xFB850ffad5349F4c8457EA8909F12BA3d63578F8;
            supaAdmin = vm.envAddress("SUPA_ADMIN_BASE");
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(deployer);
        new ProxiedOperator(dedicatedSender, supaAdmin);
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $PROXIED_OPERATOR_INIT_CODE_HASH --starts-with 0x00000000

// forge script script/deploy/periphery/proxiedOperator.s.sol:DeployProxiedOperator --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer --verify

// forge script script/deploy/periphery/proxiedOperator.s.sol:DeployProxiedOperator --rpc-url $ARBITRUM_RPC_URL --broadcast -vvvv --account supa_deployer -g 100 --etherscan-api-key $ARBISCAN_API_KEY --verify

// forge script script/deploy/periphery/proxiedOperator.s.sol:DeployProxiedOperator --rpc-url $BASE_RPC_URL --broadcast -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY --verify
