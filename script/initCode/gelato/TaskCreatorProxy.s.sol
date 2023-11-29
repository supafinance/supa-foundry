// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

contract InitCodeHashTaskCreatorProxy is Script {
    function run() external {
        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(TaskCreatorProxy).creationCode);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/gelato/TaskCreatorProxy.s.sol:InitCodeHashTaskCreatorProxy -vvvv
