// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";

contract DeployOffchainEntityProxy is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        address governator = vm.envAddress("GOVERNATOR");
        string memory entityName = vm.envString("OFFCHAIN_ENTITY_NAME");
        bytes32 salt = vm.envBytes32("OFFCHAIN_ENTITY_PROXY_SALT");
        vm.startBroadcast(owner);
        OffchainEntityProxy offchainEntityProxy = new OffchainEntityProxy{salt: salt}(governator, entityName);
        assert(address(offchainEntityProxy) == vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $OFFCHAIN_ENTITY_PROXY_INIT_CODE_HASH --starts-with 0x0FFC4A1 --case-sensitive

// forge script script/deploy/governance/OffchainEntityProxy.s.sol:DeployOffchainEntityProxy --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer --verify
