// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";
import {UniV3LPHelper} from "src/periphery/UniV3LPHelper.sol";

contract AddERC721Info is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address uniV3OracleAddress = vm.envAddress("UNI_V3_ORACLE");

        vm.startBroadcast(deployerPrivateKey);
        SupaConfig supaConfig = SupaConfig(supa);
        supaConfig.addERC721Info(manager, uniV3OracleAddress);
        vm.stopBroadcast();
    }
}

// forge script script/setup/AddERC721Info.s.sol:AddERC721Info --rpc-url $GOERLI_RPC_URL --broadcast -vvvv

