// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {VersionManager} from "src/supa/VersionManager.sol";

contract InitCodeHashVersionManager is Script {
    function run() external {
        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(governanceProxyAddress);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(VersionManager).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/supa/VersionManager.s.sol:InitCodeHashVersionManager -vvvv
