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
        } else if (chainId == 42161) {
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

// cast create2 --init-code-hash $SUPA_CONFIG_INIT_CODE_HASH --starts-with 0xB0057ED0 --case-sensitive

// forge script script/deploy/supa/Supa.s.sol:DeploySupa --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer

// forge script script/deploy/supa/Supa.s.sol:DeploySupa --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer
