// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic} from "src/wallet/WalletLogic.sol";

import {ERC20TwapOracle} from "src/oracles/ERC20TwapOracle.sol";

contract getTwapOraclePrice is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fix oracle pricing
        ERC20TwapOracle wethOracle = ERC20TwapOracle(0x88Ac4469681041C09a4126Bda535e3d060fA19e2);
        ERC20TwapOracle uniOracle = ERC20TwapOracle(0xCD7D20791AeA1f70e9AC8339cA142f0855462D15);
        (int256 tValue, int256 collateralAdjustedValue, int256 borrowAdjustedValue) = wethOracle.getValues();
        console.log("tValue: ");
        console.logInt(tValue);
        console.log("collateralAdjustedValue: ");
        console.logInt(collateralAdjustedValue);
        console.log("borrowAdjustedValue: ");
        console.logInt(borrowAdjustedValue);

        (int256 value, int256 riskAdjustedValue) = wethOracle.calcValue(1e16);
        console.log("value: ");
        console.logInt(value);
        console.log("riskAdjustedValue: ");
        console.logInt(riskAdjustedValue);
        vm.stopBroadcast();
    }
}

// forge script script/data/getTwapOraclePrice.s.sol:getTwapOraclePrice --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
