// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";

contract DeploySupa is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        address supaConfigAddress = vm.envAddress("SUPA_CONFIG_ADDRESS");
        address versionManagerAddress = vm.envAddress("VERSION_MANAGER_ADDRESS");
        bytes32 salt = vm.envBytes32("SUPA_SALT");
        vm.startBroadcast(owner);
        Supa supa = new Supa{salt: salt}(supaConfigAddress, versionManagerAddress);
        assert(address(supa) == vm.envAddress("SUPA_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $SUPA_CONFIG_INIT_CODE_HASH --starts-with 0xB0057ED0 --case-sensitive

// forge script script/deploy/supa/Supa.s.sol:DeploySupa --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
