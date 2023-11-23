// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {GovernanceProxy} from "src/governance/GovernanceProxy.sol";

contract InitCodeHashGovernanceProxy is Script {
    function run() external {
        address offchainEntityProxyAddress = vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(offchainEntityProxyAddress);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(GovernanceProxy).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/GovernanceProxy.s.sol:InitCodeHashGovernanceProxy -vvvv
