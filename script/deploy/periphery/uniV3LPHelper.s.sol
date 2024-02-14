// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract DeployUniV3LPHelper is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address deployer;
        address manager;
        address factory;
        address swapRouter;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
            address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
            address factory = vm.envAddress("UNISWAP_V3_FACTORY");
            address swapRouter = vm.envAddress("SWAP_ROUTER");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
            address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
            address factory = vm.envAddress("UNISWAP_V3_FACTORY");
            address swapRouter = vm.envAddress("SWAP_ROUTER");
        } else if (chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
            manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER_BASE");
            factory = vm.envAddress("UNISWAP_V3_FACTORY_BASE");
            swapRouter = vm.envAddress("SWAP_ROUTER_BASE");
        } else {
            revert("unsupported chain");
        }
//        bytes32 salt = vm.envBytes32("UNI_V3_LP_HELPER_SALT");
        bytes32 salt = 0xaac462e10f7324d89705c8590b850551de1d0e8091dddd90ac8ee5a86edcd9d8;
        console.log(chainId);
        console.logBytes32(salt);
        vm.startBroadcast(deployer);
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

        UniV3LPHelper uniV3LpHelper = new UniV3LPHelper{salt: salt}(manager, factory, swapRouter);
        console.logAddress(address(uniV3LpHelper));
        console.logAddress(vm.envAddress("UNI_V3_LP_HELPER_ADDRESS"));
        assert(address(uniV3LpHelper) == vm.envAddress("UNI_V3_LP_HELPER_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $UNI_V3_LP_HELPER_INIT_CODE_HASH --starts-with 0x00000000
// cast create2 --init-code-hash 0xace5ed67e4f3bf57d127da893a1695d6132151f7bae028058cdc82893d90bfb8 --starts-with 0x00000000

// forge script script/deploy/periphery/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --account supa_test_deployer
// forge script script/deploy/periphery/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $ARBITRUM_RPC_URL --broadcast --etherscan-api-key $ARBISCAN_API_KEY -vvvv --account supa_deployer
// forge script script/deploy/periphery/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $BASE_RPC_URL --broadcast --etherscan-api-key $BASESCAN_API_KEY -vvvv --account supa_deployer --verify --with-gas-price 1000000
