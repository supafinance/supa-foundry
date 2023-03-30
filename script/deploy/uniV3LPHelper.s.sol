// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract DeployUniV3LPHelper is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address swapRouter = vm.envAddress("SWAP_ROUTER");
        vm.startBroadcast(deployerPrivateKey);
        new UniV3LPHelper(supa, manager, factory, swapRouter);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
