// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.9.0;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {SupaBeta} from "src/tokens/SupaBeta.sol";

contract AddBetaUser is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
        address supaBetaProxyAddress = vm.envAddress("SUPA_BETA_PROXY_ADDRESS");
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }

        uint256 betaPowerAllocation = 50 ether;

        address user = vm.envAddress("NEW_BETA_USER");

        SupaBeta supaBeta = SupaBeta(supaBetaProxyAddress);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);

        assert(supaBeta.balanceOf(user) == 0);
        assert(taskCreator.balanceOf(user) == 0);


        vm.startBroadcast(deployer);
        supaBeta.mint(user);
        taskCreator.adminIncreasePower(user, betaPowerAllocation);
        vm.stopBroadcast();
    }
}

// forge script script/setup/AddBetaUser.s.sol:AddBetaUser --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
// forge script script/setup/AddBetaUser.s.sol:AddBetaUser --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer