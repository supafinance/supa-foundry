// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";

contract DeploySupa is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161 || chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }
        address supaConfigAddress = vm.envAddress("SUPA_CONFIG_ADDRESS");
        address versionManagerAddress = vm.envAddress("VERSION_MANAGER_ADDRESS");
        bytes32 salt = vm.envBytes32("SUPA_SALT");
        vm.startBroadcast(deployer);
        Supa supa = new Supa{salt: salt}(supaConfigAddress, versionManagerAddress);
        vm.stopBroadcast();
        assert(address(supa) == vm.envAddress("SUPA_ADDRESS"));
    }
}

// cast create2 --init-code-hash $SUPA_INIT_CODE_HASH --starts-with 0xB0057ED0 --case-sensitive

// forge script script/deploy/supa/Supa.s.sol:DeploySupa --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer

// forge script script/deploy/supa/Supa.s.sol:DeploySupa --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $ARBISCAN_API_KEY

// forge script script/deploy/supa/Supa.s.sol:DeploySupa --rpc-url $BASE_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY

// forge verify-contract 0xB0057ED0100643b4B2852799A3c3fed33947D47C Supa --constructor-args 0x00000000000000000000000000000000057d45faed7f49ba69472321b7e0901d000000000000000000000000000000009b648aa9453e3bbd236adb2982aa65b1 --chain 8453 --etherscan-api-key $BASESCAN_API_KEY --verifier etherscan

// forge verify-contract 0xB0057ED0100643b4B2852799A3c3fed33947D47C Supa --constructor-args 0x00000000000000000000000000000000057d45faed7f49ba69472321b7e0901d000000000000000000000000000000009b648aa9453e3bbd236adb2982aa65b1 --chain 42161 --etherscan-api-key $ARBISCAN_API_KEY --verifier etherscan