// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.9.0;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {SupaBeta} from "src/tokens/SupaBeta.sol";

contract AddAdmin is Script {
    function run() public virtual {
        uint256 chainId = block.chainid;
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
//        address supaBetaProxyAddress = vm.envAddress("SUPA_BETA_PROXY_ADDRESS");
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161 || chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }

        address user = 0xDf048196C83A83eFE5A56fEd1A577b65388e09d0;

//        SupaBeta supaBeta = SupaBeta(supaBetaProxyAddress);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);

        vm.startBroadcast(deployer);
//        supaBeta.setMinter(user, true);
        taskCreator.addAllowlistRole(user);
        vm.stopBroadcast();
    }
}

// forge script script/setup/AddBetaUser.s.sol:AddBetaUser --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
// forge script script/setup/AddAdmin.s.sol:AddAdmin --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer
// forge script script/setup/AddAdmin.s.sol:AddAdmin --rpc-url $BASE_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY