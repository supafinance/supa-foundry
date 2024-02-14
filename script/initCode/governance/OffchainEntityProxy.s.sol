// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";

contract InitCodeHashOffchainEntityProxy is Script {
    function run() external {
        // Replace these with the actual constructor arguments for OffchainEntityProxy
        address governator = vm.envAddress("GOVERNATOR");
        string memory entityName = vm.envString("OFFCHAIN_ENTITY_NAME");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(governator, entityName);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(OffchainEntityProxy).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/governance/OffchainEntityProxy.s.sol:InitCodeHashOffchainEntityProxy -vvvv

