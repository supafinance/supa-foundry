// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BoostModeHelper} from "src/periphery/BoostModeHelper.sol";

contract DeployBoostModeHelper is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        vm.startBroadcast(deployerPrivateKey);
        new BoostModeHelper(supa);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/boostModeHelper.s.sol:DeployBoostModeHelper --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv
