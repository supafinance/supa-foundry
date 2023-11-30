// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";

contract TransferOwnership is Script {
    function run() external {
        address governator = vm.envAddress("GOVERNATOR");
        address newOwner = vm.envAddress("OWNER");

        vm.startBroadcast(governator);
        OffchainEntityProxy offchainEntityProxy = OffchainEntityProxy(vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS"));
        offchainEntityProxy.transferOwnership(newOwner);
        vm.stopBroadcast();
    }
}

// forge script script/setup/governance/OffchainEntityProxy.transferOwnership.s.sol:TransferOwnership --rpc-url $GOERLI_RPC_URL --broadcast -vvvv -

// forge script script/setup/governance/OffchainEntityProxy.transferOwnership.s.sol:TransferOwnership --rpc-url $ARBITRUM_RPC_URL --broadcast -vvvv -t