// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

/// @notice Deploys {TaskCreatorProxy}
contract DeployTaskCreatorProxy is BaseScript {
    function run() public virtual {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address automate = vm.envAddress("AUTOMATE");
        // todo: update depending on the network
        address usdc = vm.envAddress("USDC_GOERLI");

        vm.startBroadcast(deployerPrivateKey);
        TaskCreatorProxy taskCreatorProxy = new TaskCreatorProxy();
        TaskCreator taskCreator = new TaskCreator(supa, automate, address(taskCreatorProxy), usdc);
        taskCreatorProxy.upgrade(address(taskCreator));
        vm.stopBroadcast();
    }
}

// forge script script/deploy/gelato/DeployTaskCreatorProxy.s.sol:DeployTaskCreatorProxy --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
