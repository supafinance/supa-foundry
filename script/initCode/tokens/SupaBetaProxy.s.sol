// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SupaBetaProxy} from "src/tokens/SupaBetaProxy.sol";

contract InitCodeSupaBetaProxy is Script {
    function run() external {
        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(SupaBetaProxy).creationCode);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/tokens/SupaBetaProxy.s.sol:InitCodeSupaBetaProxy -vvvv

// 0x4925a68eaab0ffeec6b4fac4aeb641cd798b866f2ed94e6f5015cc5815a2a456