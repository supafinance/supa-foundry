// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";

contract InitCodeHashSupaConfig is Script {
    function run() external {
        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(governanceProxyAddress);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(SupaConfig).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/supa/SupaConfig.s.sol:InitCodeHashSupaConfig -vvvv
