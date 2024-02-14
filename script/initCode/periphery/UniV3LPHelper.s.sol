// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract InitCodeHashUniV3LPHelper is Script {
    function run() external {
        address manager;
        address factory;
        address swapRouter;

        uint256 chainId = block.chainid;
        console.logUint(chainId);
        if (chainId == 8453) {
            manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER_BASE");
            factory = vm.envAddress("UNISWAP_V3_FACTORY_BASE");
            swapRouter = vm.envAddress("SWAP_ROUTER_BASE");
        } else if (chainId == 1 || chainId == 5 || chainId == 42161) {
            manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
            factory = vm.envAddress("UNISWAP_V3_FACTORY");
            swapRouter = vm.envAddress("SWAP_ROUTER");
        } else {
            revert("unsupported chain");
        }

        console.logAddress(manager);
        console.logAddress(factory);
        console.logAddress(swapRouter);

        // Encode the constructor arguments
        bytes memory encodedArgs = abi.encode(manager, factory, swapRouter);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(UniV3LPHelper).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/periphery/UniV3LPHelper.s.sol:InitCodeHashUniV3LPHelper -vvvv --rpc-url $BASE_RPC_URL

