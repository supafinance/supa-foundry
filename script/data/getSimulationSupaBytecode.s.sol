// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";

contract getBytecode is Script {
    function run() external {
        bytes memory bytecode = abi.encodePacked(vm.getDeployedCode("SimulationSupa.sol:SimulationSupa"));
    }
}

// forge script script/data/getSimulationSupaBytecode.s.sol:getBytecode --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
