// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.9.0;

import {Script} from "forge-std/Script.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";

contract IncreasePowerCredits is Script {
    function run() public virtual {
        address payable taskCreatorProxyAddress = payable(vm.envAddress("TASK_CREATOR_PROXY_ADDRESS"));
        uint256 chainId = block.chainid;
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161 || chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }
//        address user = 0x4141EC9F8Acfd636E7b037EB3171f4452656dA35; // Parker
//        address user = 0x8E292FE20ee2BDf29B4BC7c104641b59eAEFf457; // Derek
        address user = 0x0F4eab37086338bE99a7C895191F31c8960Eb1CB;

//        address user = 0xFB850ffad5349F4c8457EA8909F12BA3d63578F8; // base frame deployer

//        address user = 0xa9cE598b9286ACECF2E495D663FaA611256910F1;
        vm.startBroadcast(deployer);
        TaskCreator taskCreator = TaskCreator(taskCreatorProxyAddress);
        taskCreator.adminIncreasePower(user, 50 ether);
        vm.stopBroadcast();
    }
}

// forge script script/setup/increasePowerCredits.s.sol:IncreasePowerCredits --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
// forge script script/setup/increasePowerCredits.s.sol:IncreasePowerCredits --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer
// forge script script/setup/increasePowerCredits.s.sol:IncreasePowerCredits --rpc-url $BASE_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY