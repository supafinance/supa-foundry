// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {GelatoOperator} from "src/periphery/GelatoOperator.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {Execution} from "src/lib/Call.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";

contract CreateWallet is Script {
    function run() external {
       address deployer = vm.envAddress("DEPLOYER");

        address payable supaAddress = payable(vm.envAddress("SUPA_ADDRESS"));
        SupaConfig supa = SupaConfig(supaAddress);

        vm.startBroadcast(deployer);
        uint256 nonce = 1_000_000_000_000;
        supa.createWallet(nonce);
        vm.stopBroadcast();
    }
}

// forge script script/CreateWallet.s.sol:CreateWallet --rpc-url $BASE_RPC_URL --broadcast -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY
