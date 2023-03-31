// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";
import {ERC20ChainlinkValueOracle} from "src/oracles/ERC20ChainlinkValueOracle.sol";

contract DeployERC20ChainlinkValueOracle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address usdcAddress = vm.envAddress("USDC");
        address wethAddress = vm.envAddress("WETH");
        address uniAddress = vm.envAddress("UNI");
        address owner = vm.envAddress("OWNER");

        address usdcChainlinkOracle;
        address wethChainlinkOracle;
        address uniChainlinkOracle;

        uint8 chainlinkBaseDecimals = 8;
        uint8 usdcTokenDecimals = 6;
        int256 collateralFactor = 0.95 ether;
        int256 borrowFactor = 0.95 ether;

        uint8 wethTokenDecimals = 18;
        uint8 uniTokenDecimals = 18;

        vm.startBroadcast(deployerPrivateKey);
        ERC20ChainlinkValueOracle usdcOracle =
        new ERC20ChainlinkValueOracle(usdcChainlinkOracle, chainlinkBaseDecimals, usdcTokenDecimals, collateralFactor, borrowFactor, owner);
        ERC20ChainlinkValueOracle wethOracle =
        new ERC20ChainlinkValueOracle(wethChainlinkOracle, chainlinkBaseDecimals, wethTokenDecimals, collateralFactor, borrowFactor, owner);
        ERC20ChainlinkValueOracle uniOracle =
        new ERC20ChainlinkValueOracle(uniChainlinkOracle, chainlinkBaseDecimals, uniTokenDecimals, collateralFactor, borrowFactor, owner);

        SupaConfig supaConfig = SupaConfig(supa);
        supaConfig.setERC20Data(usdcAddress, address(usdcOracle), 0, 5, 480, 0.8 ether);
        supaConfig.setERC20Data(wethAddress, address(wethOracle), 0, 5, 480, 0.8 ether);
        supaConfig.setERC20Data(uniAddress, address(uniOracle), 0, 5, 480, 0.8 ether);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/oracles/ERC20ChainlinkValueOracle.s.sol:ERC20ChainlinkValueOracle --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
