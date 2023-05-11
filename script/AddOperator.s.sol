// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {GelatoOperator} from "src/periphery/GelatoOperator.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {Call} from "src/lib/Call.sol";
import {Supa} from "src/supa/Supa.sol";

contract AddOperator is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");

        address supa = vm.envAddress("SUPA");
        WalletLogic wallet = WalletLogic(0x763b978Ae1B31Cb4D6E2c95cFf7e1806725e475B);
        address operator = 0x8654202c6F3Ee519808488571D16398aF608f041;

        vm.startBroadcast(deployerPrivateKey);
        Call[] memory calls = new Call[](1);
        calls[0] = Call({to: supa, callData: abi.encodeWithSelector(Supa.addOperator.selector, operator), value: 0});
        wallet.executeBatch(calls);
        vm.stopBroadcast();
    }
}

// forge script script/AddOperator.s.sol:AddOperator --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
