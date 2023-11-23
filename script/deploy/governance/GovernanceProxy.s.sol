// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {GovernanceProxy} from "src/governance/GovernanceProxy.sol";

contract DeployGovernanceProxy is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        address offchainEntityProxyAddress = vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS");
        bytes32 salt = vm.envBytes32("GOVERNANCE_PROXY_SALT");
        vm.startBroadcast(owner);
        GovernanceProxy governanceProxy = new GovernanceProxy{salt: salt}(offchainEntityProxyAddress);
        assert(address(governanceProxy) == vm.envAddress("GOVERNANCE_PROXY_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $GOVERNANCE_PROXY_INIT_CODE_HASH --starts-with 0xDEC1DE --case-sensitive

// forge script script/deploy/governance/GovernanceProxy.s.sol:DeployGovernanceProxy --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
