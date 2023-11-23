// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";

contract SetERC20Data is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");

        address weth = vm.envAddress("WETH_GOERLI");
        address usdc = vm.envAddress("USDC_GOERLI");
        address uni = vm.envAddress("UNI"); // uni is the same on goerli and mainnet

        address wethOracle = vm.envAddress("WETH_TWAP");
        address usdcOracle = vm.envAddress("USDC_ORACLE");
        address uniOracle = vm.envAddress("UNI_ORACLE");

        uint256 baseRate = 0;
        uint256 slope1 = 2;
        uint256 slope2 = 480;
        uint256 targetUtilization = 8e17;

        vm.startBroadcast(deployerPrivateKey);
        SupaConfig supaConfig = SupaConfig(supa);
        supaConfig.setERC20Data(weth, wethOracle, baseRate, slope1, slope2, targetUtilization);
        // supaConfig.setERC20Data(usdc, usdcOracle, baseRate, slope1, slope2, targetUtilization);
        // supaConfig.setERC20Data(uni, uniOracle, baseRate, slope1, slope2, targetUtilization);
        vm.stopBroadcast();
    }
}

// forge script script/setup/setERC20Data.s.sol:SetERC20Data --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
