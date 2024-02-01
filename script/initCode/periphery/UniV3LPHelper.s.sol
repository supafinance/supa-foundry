// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract InitCodeHashUniV3LPHelper is Script {
    function run() external {
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address swapRouter = vm.envAddress("SWAP_ROUTER");

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(manager, factory, swapRouter);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(UniV3LPHelper).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/periphery/UniV3LPHelper.s.sol:InitCodeHashUniV3LPHelper -vvvv

