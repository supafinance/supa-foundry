// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager} from "src/supa/VersionManager.sol";

contract DeploySupa is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER");
        vm.startBroadcast(deployerPrivateKey);
        VersionManager versionManager = new VersionManager(owner);
        SupaConfig supaConfig = new SupaConfig(owner);
        Supa supa = new Supa(address(supaConfig), address(versionManager));
        vm.stopBroadcast();
    }
}

// forge script script/DeploySupa.s.sol:DeploySupa --rpc-url $GOERLI_RPC_URL --broadcast -vvvv

// forge script script/DeploySupa.s.sol:DeploySupa --rpc-url $POLYGON_RPC_URL --broadcast -vvvv

