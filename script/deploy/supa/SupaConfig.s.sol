// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";

contract DeploySupaConfig is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        uint256 salt = vm.envUint("SUPA_CONFIG_SALT");
        vm.startBroadcast(owner);
        SupaConfig supaConfig = new SupaConfig{salt: bytes32(salt)}(governanceProxyAddress);
        assert(address(supaConfig) == vm.envAddress("SUPA_CONFIG_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $SUPA_CONFIG_INIT_CODE_HASH --starts-with 0x000000000

// forge script script/deploy/supa/SupaConfig.s.sol:DeploySupaConfig --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
