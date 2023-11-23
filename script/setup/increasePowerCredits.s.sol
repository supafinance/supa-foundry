// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.9.0;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract IncreasePowerCredits is Script {
    function run() public virtual {
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        address owner = 0xc9B6088732E83ef013873e2f04d032F1a7a2E42D;
        address user = 0x4141EC9F8Acfd636E7b037EB3171f4452656dA35;

        vm.startBroadcast(owner);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.addAllowlistRole(owner);
        taskCreator.adminIncreasePower(user, 1 ether);
        vm.stopBroadcast();
    }
}

// forge script script/setup/increasePowerCredits.s.sol:IncreasePowerCredits --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer