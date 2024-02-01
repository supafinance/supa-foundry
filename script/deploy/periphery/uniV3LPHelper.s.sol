// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract DeployUniV3LPHelper is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address swapRouter = vm.envAddress("SWAP_ROUTER");
        bytes32 salt = vm.envBytes32("UNI_V3_LP_HELPER_SALT");
        vm.startBroadcast(deployer);
        UniV3LPHelper uniV3LpHelper = new UniV3LPHelper{salt: salt}(manager, factory, swapRouter);
        assert(address(uniV3LpHelper) == vm.envAddress("UNI_V3_LP_HELPER_ADDRESS"));
        vm.stopBroadcast();
    }
}

// forge script script/deploy/periphery/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --account supa_test_deployer
// forge script script/deploy/periphery/uniV3LPHelper.s.sol:DeployUniV3LPHelper --rpc-url $ARBITRUM_RPC_URL --broadcast --etherscan-api-key $ARBISCAN_API_KEY -vvvv --account supa_deployer
