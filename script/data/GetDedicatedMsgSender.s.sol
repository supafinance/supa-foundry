// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

import {Module, IAutomate, IProxyModule, IOpsProxyFactory} from "src/gelato/Types.sol";

contract GetDedicatedMsgSender is Script {
    function run() public view {
        address automate = vm.envAddress("AUTOMATE");
        address taskCreator = 0x459ba2a63cB8E306555b563236b4d1f23B047122;

        address proxyModuleAddress = IAutomate(automate).taskModuleAddresses(Module.PROXY);

        address opsProxyFactoryAddress = IProxyModule(proxyModuleAddress).opsProxyFactory();

        (address dedicatedMsgSender,) = IOpsProxyFactory(opsProxyFactoryAddress).getProxyOf(taskCreator);

        console.log("DEDICATED_MSG_SENDER", dedicatedMsgSender);
    }
}

// forge script script/data/GetDedicatedMsgSender.s.sol:GetDedicatedMsgSender --rpc-url $GOERLI_RPC_URL --broadcast -vvvv