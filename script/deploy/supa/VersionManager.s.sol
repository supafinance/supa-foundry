// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VersionManager} from "src/supa/VersionManager.sol";

contract DeployVersionManager is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        bytes32 salt = vm.envBytes32("VERSION_MANAGER_SALT");
        vm.startBroadcast(owner);
        VersionManager versionManager = new VersionManager{salt: salt}(governanceProxyAddress);
        assert(address(versionManager) == vm.envAddress("VERSION_MANAGER_ADDRESS"));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $VERSION_MANAGER_INIT_CODE_HASH --starts-with 0x00000000

// forge script script/deploy/supa/VersionManager.s.sol:DeployVersionManager --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
