// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

contract InitCodeHashGelatoOperator is Script {
    function run() external {
        address gelatoDedicatedSender = vm.envAddress("GELATO_DEDICATED_SENDER");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(gelatoDedicatedSender);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(GelatoOperator).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/periphery/GelatoOperator.s.sol:InitCodeHashGelatoOperator -vvvv

