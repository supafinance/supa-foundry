// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";

contract TransferOwnership is Script {
    function run() external {
        address deployer = vm.envAddress("DEPLOYER");
        address newOwner = vm.envAddress("SUPA_ADMIN");

        vm.startBroadcast(deployer);
        OffchainEntityProxy offchainEntityProxy = OffchainEntityProxy(vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS"));
        offchainEntityProxy.transferOwnership(newOwner);
        vm.stopBroadcast();
    }
}

// forge script script/setup/governance/OffchainEntityProxy.transferOwnership.s.sol:TransferOwnership --rpc-url $GOERLI_RPC_URL --broadcast -vvvv -

// forge script script/setup/governance/OffchainEntityProxy.transferOwnership.s.sol:TransferOwnership --rpc-url $ARBITRUM_RPC_URL --broadcast -vvvv --account supa_deployer -g 100