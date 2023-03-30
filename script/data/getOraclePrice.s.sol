// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import { WalletLogic } from "src/wallet/WalletLogic.sol";

import {MockERC20Oracle } from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract getOraclePrice is Script {
    function run() external {

        address usdcOracleAddress = vm.envAddress("USDC_ORACLE");
        address wethOracleAddress = vm.envAddress("ETH_ORACLE");
        address uniOracleAddress = vm.envAddress("UNI_ORACLE");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fix oracle pricing
        console.log("usdcOracleAddress: ", usdcOracleAddress);
        MockERC20Oracle usdcOracle = MockERC20Oracle(usdcOracleAddress);
        (int256 value, int256 riskAdjustedValue) = usdcOracle.calcValue(1e6);
        console.log("value: ");
        console.logInt(value);
        console.log("riskAdjustedValue: ");
        console.logInt(riskAdjustedValue);
        vm.stopBroadcast();
    }
}

// forge script script/data/getOraclePrice.s.sol:getOraclePrice --rpc-url $GOERLI_RPC_URL --broadcast -vvvv