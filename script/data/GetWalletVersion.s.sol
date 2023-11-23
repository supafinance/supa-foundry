// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";

import {Supa} from "src/supa/Supa.sol";
import { VersionManager } from "src/supa/VersionManager.sol";

contract GetWalletVersion is Script {
    function run() external {
        address walletAddress = 0x554402F0dbe8f5488a3D77a6BF15476Bc57F2cce;

        address supaAddress = vm.envAddress("SUPA");

        Supa supa = Supa(payable(supaAddress));

        address walletImplementation = supa.getImplementation(walletAddress);
        console.log('walletImplementation:', walletImplementation);

        VersionManager versionManager = VersionManager(address(supa.versionManager()));

        (string memory versionName, ,,address implementation, uint256 dateAdded) = versionManager.getRecommendedVersion();
        console.log('versionName:', versionName);
        console.log('implementation:', implementation);
        console.log('dateAdded:', dateAdded);
    }
}

// forge script script/data/GetWalletVersion.s.sol:GetWalletVersion --rpc-url $GOERLI_RPC_URL --broadcast -vvvv

