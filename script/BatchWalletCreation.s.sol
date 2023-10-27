// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {Call} from "src/lib/Call.sol";

contract BatchWalletCreation is Script {
    function run() external {
        address supa = vm.envAddress("SUPA");
        WalletLogic wallet = WalletLogic(0x554402F0dbe8f5488a3D77a6BF15476Bc57F2cce);

        vm.startBroadcast(0xd6451958cFefD7EE2dE840Ab2bA55039702C8bD1);
        Call[] memory calls = new Call[](5);
        calls[0] = Call({to: supa, callData: abi.encodeWithSelector(SupaConfig.createWallet.selector), value: 0});
        calls[1] = Call({to: supa, callData: abi.encodeWithSelector(SupaConfig.createWallet.selector), value: 0});
        calls[2] = Call({to: supa, callData: abi.encodeWithSelector(SupaConfig.createWallet.selector), value: 0});
        calls[3] = Call({to: supa, callData: abi.encodeWithSelector(SupaConfig.createWallet.selector), value: 0});
        calls[4] = Call({to: supa, callData: abi.encodeWithSelector(SupaConfig.createWallet.selector), value: 0});
        wallet.executeBatch(calls);
        vm.stopBroadcast();
    }
}

// forge script script/BatchWalletCreation.s.sol:BatchWalletCreation --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account personal_test_1