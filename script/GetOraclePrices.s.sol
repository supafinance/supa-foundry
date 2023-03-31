// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic} from "src/wallet/WalletLogic.sol";

import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract GetOraclePrices is Script {
    function run() external {
        address usdcOracleAddress = vm.envAddress("USDC_ORACLE");
        address wethOracleAddress = vm.envAddress("ETH_ORACLE");
        address uniOracleAddress = vm.envAddress("UNI_ORACLE");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fix oracle pricing
        MockERC20Oracle usdcOracle = MockERC20Oracle(usdcOracleAddress);
        (int256 usdcValue, int256 usdcCollateralValue, int256 usdcBorrowValue) = usdcOracle.getValues();
        console.log("usdcValue");
        console.logInt(usdcValue);
        console.log("usdcCollateralValue");
        console.logInt(usdcCollateralValue);
        console.log("usdcBorrowValue");
        console.logInt(usdcBorrowValue);

        (int256 calcValue, int256 calcRiskAdjustedValue) = usdcOracle.calcValue(1e6);
        console.log("calcValue");
        console.logInt(calcValue);
        console.log("calcRiskAdjustedValue");
        console.logInt(calcRiskAdjustedValue);

        MockERC20Oracle wethOracle = MockERC20Oracle(wethOracleAddress);
        (int256 wethValue, int256 wethCollateralValue, int256 wethBorrowValue) = wethOracle.getValues();
        console.log("wethValue");
        console.logInt(wethValue);
        console.log("wethCollateralValue");
        console.logInt(wethCollateralValue);
        console.log("wethBorrowValue");
        console.logInt(wethBorrowValue);

        MockERC20Oracle uniOracle = MockERC20Oracle(uniOracleAddress);
        (int256 uniValue, int256 uniCollateralValue, int256 uniBorrowValue) = uniOracle.getValues();
        console.log("uniValue");
        console.logInt(uniValue);
        console.log("uniCollateralValue");
        console.logInt(uniCollateralValue);
        console.log("uniBorrowValue");
        console.logInt(uniBorrowValue);

        vm.stopBroadcast();
    }
}

// forge script script/GetOraclePrices.s.sol:GetOraclePrices --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
