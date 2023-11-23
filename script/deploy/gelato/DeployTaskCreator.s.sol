// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {Script, console} from "forge-std/Script.sol";

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator, ITaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

/// @notice Deploys {TaskCreator}
contract DeployTaskCreator is BaseScript {
    function run() public virtual {
        address supa = vm.envAddress("SUPA");
        address automate = vm.envAddress("AUTOMATE");
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address owner = 0xc9B6088732E83ef013873e2f04d032F1a7a2E42D;
        // todo: update depending on the network
        address usdc = vm.envAddress("USDC_GOERLI");
        address allowlistServer = 0xDf048196C83A83eFE5A56fEd1A577b65388e09d0;
        vm.startBroadcast(owner);
        TaskCreator taskCreator = new TaskCreator(supa, automate, taskCreatorProxyAddress, usdc);
        TaskCreatorProxy taskCreatorProxy = TaskCreatorProxy(taskCreatorProxyAddress);
        taskCreatorProxy.upgrade(address(taskCreator));

        address ethPriceFeedGoerli = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
        TaskCreator(payable(address(taskCreatorProxy))).addAllowlistRole(owner);
        TaskCreator(payable(address(taskCreatorProxy))).addAllowlistRole(allowlistServer);
        TaskCreator(payable(address(taskCreatorProxy))).setFeeCollector(allowlistServer);
        TaskCreator(payable(address(taskCreatorProxy))).setGasPriceFeed(ethPriceFeedGoerli);
        ITaskCreator.Tier[] memory tiers = new ITaskCreator.Tier[](1);
        tiers[0] = ITaskCreator.Tier({
            limit: 0,
            rate: 1e6
        });
        TaskCreator(payable(address(taskCreatorProxy))).setTiers(tiers);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/DeployTaskCreator.s.sol:DeployTaskCreator --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
