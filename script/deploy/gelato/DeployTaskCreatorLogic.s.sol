// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {BaseScript} from "script/Base.s.sol";
import {TaskCreatorLogic} from "src/gelato/TaskCreatorLogic.sol";

/// @notice Deploys {TaskCreator}
contract DeployTaskCreatorLogic is BaseScript {
    function run() public virtual {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address automate = vm.envAddress("AUTOMATE");
        address payable taskCreatorProxy = payable(vm.envAddress("TASK_CREATOR_PROXY"));
        vm.startBroadcast(deployerPrivateKey);
        TaskCreatorLogic taskCreatorLogic = new TaskCreatorLogic(supa, automate, taskCreatorProxy);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/DeployTaskCreatorLogic.s.sol:DeployTaskCreatorLogic --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
