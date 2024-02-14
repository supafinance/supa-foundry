// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {ProxiedOperator} from "src/periphery/ProxiedOperator.sol";

contract InitCodeHashProxiedOperator is Script {
    function run() external {
        uint256 chainId = block.chainid;

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(ProxiedOperator).creationCode);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/periphery/ProxiedOperator.s.sol:InitCodeHashProxiedOperator -vvvv

