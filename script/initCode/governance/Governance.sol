// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Governance} from "src/governance/Governance.sol";

contract InitCodeHashGovernanceProxy is Script {
    function run() external {
        address offchainEntityProxyAddress = vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(offchainEntityProxyAddress);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(Governance).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/GovernanceProxy.s.sol:InitCodeHashGovernanceProxy --rpc-url $GOERLI_RPC_URL -vvvv

