// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic} from "src/wallet/WalletLogic.sol";

import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract GetRiskAdjustedPositionValues is Script {
    function run() external {
        address supaAddress = vm.envAddress("SUPA");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address walletAddress = 0x763b978Ae1B31Cb4D6E2c95cFf7e1806725e475B;
        vm.startBroadcast(deployerPrivateKey);

        // Fix oracle pricing
        Supa supa = Supa(payable(supaAddress));
        (int256 totalValue, int256 collateral, int256 debt) = supa.getRiskAdjustedPositionValues(walletAddress);
        console.log("totalValue");
        console.logInt(totalValue);
        console.log("collateral");
        console.logInt(collateral);
        console.log("debt");
        console.logInt(debt);

        vm.stopBroadcast();
    }
}

// forge script script/GetRiskAdjustedPositionValues.s.sol:GetRiskAdjustedPositionValues --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
