// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

contract DeployGelatoOperator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address dedicatedSender = vm.envAddress("GELATO_DEDICATED_SENDER");
        vm.startBroadcast(deployerPrivateKey);
        new GelatoOperator(dedicatedSender);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelatoOperator.s.sol:DeployGelatoOperator --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
