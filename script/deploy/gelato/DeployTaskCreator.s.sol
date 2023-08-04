// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

/// @notice Deploys {TaskCreator}
contract DeployTaskCreator is BaseScript {
    function run() public virtual {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address automate = vm.envAddress("AUTOMATE");
        vm.startBroadcast(deployerPrivateKey);
        TaskCreator taskCreator = new TaskCreator(supa, automate);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/DeployTaskCreator.s.sol:DeployTaskCreator --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
