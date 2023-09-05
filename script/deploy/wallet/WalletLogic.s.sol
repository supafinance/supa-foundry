// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {IVersionManager, VersionManager} from "src/supa/VersionManager.sol";

contract DeployWalletLogic is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address versionManagerAddress = vm.envAddress("VERSION_MANAGER");
        vm.startBroadcast(deployerPrivateKey);
        WalletLogic walletLogic = new WalletLogic(supa);
        VersionManager versionManager = VersionManager(versionManagerAddress);
        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(walletLogic));
        versionManager.markRecommendedVersion("1.1.0");
        vm.stopBroadcast();
    }
}

// forge script script/deploy/wallet/WalletLogic.s.sol:DeployWalletLogic --rpc-url $GOERLI_RPC_URL --broadcast -vvvv