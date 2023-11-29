// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19 <=0.9.0;

import {BaseScript} from "script/Base.s.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";

/// @notice Deploys {TaskCreatorProxy}
contract DeployTaskCreatorProxy is BaseScript {
    function run() public virtual {
        address owner;
        address supa = vm.envAddress("SUPA_ADDRESS");
        address automate = vm.envAddress("AUTOMATE");

        uint256 chainId = block.chainid;
        address usdc;
        if (chainId == 5) {
                usdc = vm.envAddress("USDC_GOERLI");
                owner = vm.envAddress("OWNER_GOERLI");
        } else if (chainId == 1) {
                usdc = vm.envAddress("USDC_MAINNET");
        } else if (chainId == 42161) {
                usdc = vm.envAddress("USDC_ARBITRUM");
                owner = vm.envAddress("DEPLOYER");
        } else {
            revert("DeployTaskCreatorProxy: unsupported chain");
        }

        if (usdc == address(0)) revert("DeployTaskCreatorProxy: unsupported chain");

        bytes32 salt = vm.envBytes32("TASK_CREATOR_PROXY_SALT");

        vm.startBroadcast(owner);
        TaskCreatorProxy taskCreatorProxy = new TaskCreatorProxy{salt: salt}();
        assert(address(taskCreatorProxy) == vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
        TaskCreator taskCreator = new TaskCreator(supa, automate, address(taskCreatorProxy), usdc);
        taskCreatorProxy.upgrade(address(taskCreator));
        vm.stopBroadcast();
    }
}

// cast create2 --init-code-hash $TASK_CREATOR_PROXY_INIT_CODE_HASH --starts-with 0xB0057C0DE

// forge script script/deploy/gelato/DeployTaskCreatorProxy.s.sol:DeployTaskCreatorProxy --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
// forge script script/deploy/gelato/DeployTaskCreatorProxy.s.sol:DeployTaskCreatorProxy --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer
