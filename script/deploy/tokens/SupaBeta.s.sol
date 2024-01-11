// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SupaBeta} from "src/tokens/SupaBeta.sol";
import {SupaBetaProxy} from "src/tokens/SupaBetaProxy.sol";

contract DeploySupaBeta is Script {
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
        vm.startBroadcast(deployer);
        SupaBeta supaBeta = new SupaBeta();
        SupaBetaProxy supaBetaProxy = SupaBetaProxy(payable(vm.envAddress("SUPA_BETA_PROXY_ADDRESS")));
        supaBetaProxy.upgrade(address(supaBeta));
//        supaBeta.mint(owner);
//        supaBeta.mint(0xd6451958cFefD7EE2dE840Ab2bA55039702C8bD1);
//        supaBeta.mint(0xfD0B122e933b794d48D93D1904e768d39ebc30C0);
//        supaBeta.mint(0x4141EC9F8Acfd636E7b037EB3171f4452656dA35);
//        supaBeta.mint(0x484B20A65916B474e5ad2F6d492Ae2AA202dd6d4);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/tokens/SupaBeta.s.sol:DeploySupaBeta --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
// forge script script/deploy/tokens/SupaBeta.s.sol:DeploySupaBeta --rpc-url $ARBITRUM_RPC_URL --broadcast -vvvv --account supa_deployer
