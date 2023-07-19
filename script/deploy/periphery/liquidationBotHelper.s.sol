// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {LiquidationBotHelper} from "src/periphery/LiquidationBotHelper.sol";

contract DeployLiquidationBotHelper is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        vm.startBroadcast(deployerPrivateKey);
        new LiquidationBotHelper(supa);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/periphery/liquidationBotHelper.s.sol:DeployLiquidationBotHelper --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv
