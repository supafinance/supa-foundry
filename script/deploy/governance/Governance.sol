// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Governance} from "src/governance/Governance.sol";

contract DeployGovernance is Script {
    function run() external {
         address owner = vm.envAddress("OWNER");
         address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        address hashNFTAddress = vm.envAddress("HASH_NFT_ADDRESS");
        address votingAddress = vm.envAddress("VOTING_ADDRESS");
         bytes32 salt = vm.envBytes32("GOVERNANCE_SALT");
         vm.startBroadcast(owner);
         Governance governance = new Governance{salt: salt}(governanceProxyAddress, hashNFTAddress, votingAddress);
         assert(address(governance) == vm.envAddress("GOVERNANCE_ADDRESS"));
         vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $GOVERNANCE_INIT_CODE_HASH --starts-with 0xDEC1DE --case-sensitive

// forge script script/deploy/governance/Governance.s.sol:DeployGovernance --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
