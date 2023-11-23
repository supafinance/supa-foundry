// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SimulationSupa} from "src/testing/SimulationSupa.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager} from "src/supa/VersionManager.sol";

contract DeploySimulationSupa is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER");
        vm.startBroadcast(deployerPrivateKey);
        SimulationSupa supa =
        new SimulationSupa(address(0xf1a53c92D5bE1E78Fa416415dDdC4Dc39AFEBd16), address(0xfE6939D2B10FDc83c756B1Ab3d6bF7D580dAd2B6));
        vm.stopBroadcast();
    }
}

// forge script script/DeploySimulationSupa.s.sol:DeploySimulationSupa --rpc-url $GOERLI_RPC_URL --broadcast -vvvv

// forge script script/DeploySimulationSupa.s.sol:DeploySimulationSupa --rpc-url $POLYGON_RPC_URL --broadcast -vvvv
