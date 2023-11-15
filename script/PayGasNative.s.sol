// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";

import {TaskCreator, ITaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";
import {WalletProxy, Call} from "src/wallet/WalletProxy.sol";

contract PayGasNative is Script {
    function run() public virtual {
        address supa = vm.envAddress("SUPA");
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address supaWalletOwner = 0xd6451958cFefD7EE2dE840Ab2bA55039702C8bD1;
        address supaWalletAddress = 0x554402F0dbe8f5488a3D77a6BF15476Bc57F2cce;
        vm.startBroadcast(supaWalletOwner);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        WalletProxy supaWallet = WalletProxy(payable(supaWalletAddress));
        Call[] memory calls = new Call[](1);
        uint256 gasAmount = 5733810;
        calls[0] = Call({
            to: taskCreatorProxyAddress,
            callData: abi.encodeWithSelector(taskCreator.payGasNative.selector, gasAmount),
            value: gasAmount
        });
        supaWallet.executeBatch(calls);
        vm.stopBroadcast();
    }
}

// forge script script/PayGasNative.s.sol:PayGasNative --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account personal_test_1
