// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";

contract InitCodeHashSupa is Script {
    function run() external {
        address supaConfigAddress = vm.envAddress("SUPA_CONFIG_ADDRESS");
        address versionManagerAddress = vm.envAddress("VERSION_MANAGER_ADDRESS");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(supaConfigAddress, versionManagerAddress);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(Supa).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/supa/Supa.s.sol:InitCodeHashSupa -vvvv
