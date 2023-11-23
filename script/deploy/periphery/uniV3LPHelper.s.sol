// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract DeployUniV3LPHelper is Script {
    function run() external {
        address supa = vm.envAddress("SUPA");
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address swapRouter = vm.envAddress("SWAP_ROUTER");
        address weth = vm.envAddress("WETH_GOERLI");
        address usdc = vm.envAddress("USDC_GOERLI");
        address uni = vm.envAddress("UNI");
        address owner = vm.envAddress("OWNER");
        vm.startBroadcast(owner);
        UniV3LPHelper uniV3LpHelper = new UniV3LPHelper(supa, manager, factory, swapRouter);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/periphery/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --account supa_test_deployer
