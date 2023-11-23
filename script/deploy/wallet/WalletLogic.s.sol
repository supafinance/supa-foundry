// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {SupaState} from "src/supa/SupaState.sol";

contract DeployWalletLogic is Script {
    function run() external {
        address supa = vm.envAddress("SUPA");
        address owner = vm.envAddress("OWNER");
        vm.startBroadcast(owner);
        WalletLogic walletLogic = new WalletLogic();
        VersionManager versionManager = VersionManager(address(IVersionManager(SupaState(supa).versionManager())));
        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(walletLogic));
        versionManager.markRecommendedVersion("1.3.2");
        vm.stopBroadcast();
    }
}

// forge script script/deploy/wallet/WalletLogic.s.sol:DeployWalletLogic --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
