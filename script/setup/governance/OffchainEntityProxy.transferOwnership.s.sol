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
        offchainEntityProxy.takeOwnership(hex"b18f27f7d6806aa9e660dd64d784693d9b490fd9e9ec82dae7c981311059da7b27a8de88f86875dbf3e0c03c387c9855e81cb5cbf2b6a74cd597e2f3d7791b891b");
        vm.stopBroadcast();
    }
}

// forge script script/setup/governance/OffchainEntityProxy.transferOwnership.s.sol:TransferOwnership --rpc-url $GOERLI_RPC_URL --broadcast -vvvv -
