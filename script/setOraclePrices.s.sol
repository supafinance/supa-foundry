// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic} from "src/wallet/WalletLogic.sol";

import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract SetOraclePrices is Script {
    function run() external {
        address usdcAddress = vm.envAddress("USDC");

        address usdcOracleAddress = vm.envAddress("USDC_ORACLE");
        address wethOracleAddress = vm.envAddress("ETH_ORACLE");
        address uniOracleAddress = vm.envAddress("UNI_ORACLE");

        address uniV3OracleAddress = vm.envAddress("UNI_V3_ORACLE");

        address owner = vm.envAddress("OWNER");
        address supaAddress = vm.envAddress("SUPA");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Fix oracle pricing
        MockERC20Oracle usdcOracle = MockERC20Oracle(usdcOracleAddress);
        usdcOracle.setPrice(1e6, 6, 0);
        usdcOracle.setRiskFactors(0.95 ether, 0.95 ether);

        // UniV3Oracle uniV3Oracle = UniV3Oracle(uniV3OracleAddress);
        // uniV3Oracle.setERC20ValueOracle(usdcAddress, address(usdcOracle));

        // SupaConfig supaConfig = SupaConfig(supaAddress);
        // supaConfig.setERC20Data(usdcAddress, address(usdcOracle), 0, 5, 480, 0.8 ether);

        // usdcOracle.calcValue(1e6);
        // MockERC20Oracle wethOracle = MockERC20Oracle(wethOracleAddress);
        // wethOracle.setPrice(12e8, 6, 18);
        // wethOracle.setRiskFactors(0.95 ether, 0.95 ether);
        // MockERC20Oracle uniOracle = MockERC20Oracle(uniOracleAddress);
        // uniOracle.setPrice(2e8, 6, 18);
        // uniOracle.setRiskFactors(0.95 ether, 0.95 ether);

        vm.stopBroadcast();
    }
}

// forge script script/setOraclePrices.s.sol:SetOraclePrices --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
