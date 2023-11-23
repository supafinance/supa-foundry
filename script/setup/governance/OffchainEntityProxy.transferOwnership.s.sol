// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";

contract TransferOwnership is Script {
    function run() external {
        address governator = vm.envAddress("GOVERNATOR");
        address newOwner = vm.envAddress("NEW_OWNER");
        vm.startBroadcast(governator);
        OffchainEntityProxy offchainEntityProxy = OffchainEntityProxy(vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS"));
        offchainEntityProxy.transferOwnership(newOwner);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/governance/OffchainEntityProxy.s.sol:DeployOffchainEntityProxy --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer --verify
