// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";

contract DeploySupaConfig is Script {
    function run() external {
        uint256 chainId = block.chainid;

        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }
        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        uint256 salt = vm.envUint("SUPA_CONFIG_SALT");
        vm.startBroadcast(deployer);
        SupaConfig supaConfig = new SupaConfig{salt: bytes32(salt)}(governanceProxyAddress);
        assert(address(supaConfig) == vm.envAddress("SUPA_CONFIG_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $SUPA_CONFIG_INIT_CODE_HASH --starts-with 0x000000000

// forge script script/deploy/supa/SupaConfig.s.sol:DeploySupaConfig --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer

// forge script script/deploy/supa/SupaConfig.s.sol:DeploySupaConfig --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer
