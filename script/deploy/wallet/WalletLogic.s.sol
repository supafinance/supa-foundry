// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {SupaState} from "src/supa/SupaState.sol";

contract DeployWalletLogic is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        vm.startBroadcast(deployerPrivateKey);
        WalletLogic walletLogic = new WalletLogic(supa);
        VersionManager versionManager = VersionManager(address(IVersionManager(SupaState(supa).versionManager())));
        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(walletLogic));
        versionManager.markRecommendedVersion("1.2.0");
        vm.stopBroadcast();
    }
}

// forge script script/deploy/wallet/WalletLogic.s.sol:DeployWalletLogic --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
