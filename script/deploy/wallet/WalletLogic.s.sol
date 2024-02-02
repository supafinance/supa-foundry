// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {SupaState} from "src/supa/SupaState.sol";

contract DeployWalletLogic is Script {
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
        address versionManagerAddress = vm.envAddress("VERSION_MANAGER_ADDRESS");
        vm.startBroadcast(deployer);
        WalletLogic walletLogic = new WalletLogic();
//        VersionManager versionManager = VersionManager(versionManagerAddress);
//        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(walletLogic));
//        string memory version = walletLogic.VERSION();
//        versionManager.markRecommendedVersion(version);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/wallet/WalletLogic.s.sol:DeployWalletLogic --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
// forge script script/deploy/wallet/WalletLogic.s.sol:DeployWalletLogic --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $ARBISCAN_API_KEY