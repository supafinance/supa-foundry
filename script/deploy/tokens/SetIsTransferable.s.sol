// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SupaBeta} from "src/tokens/SupaBeta.sol";

contract MintBetaNft is Script {
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
        address supaBetaProxy = vm.envAddress("SUPA_BETA_PROXY_ADDRESS");
        vm.startBroadcast(deployer);
        bool isTransferable = true;
        SupaBeta(address(supaBetaProxy)).setIsTransferable(isTransferable);

        vm.stopBroadcast();
    }
}

// forge script script/deploy/tokens/MintBetaNft.s.sol:MintBetaNft --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer
// forge script script/deploy/tokens/MintBetaNft.s.sol:MintBetaNft --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer -g 100