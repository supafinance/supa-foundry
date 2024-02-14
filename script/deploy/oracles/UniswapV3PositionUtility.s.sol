// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniswapV3PositionUtility} from "src/oracles/UniswapV3PositionUtility.sol";

contract DeployUniswapV3PositionUtility is Script {
    function run() external {
        uint256 chainId = block.chainid;
        console.logUint(chainId);
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161 || chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }

        console.logAddress(deployer);

        bytes32 salt = vm.envBytes32("SUPA_SALT");

        vm.startBroadcast(deployer);
        UniswapV3PositionUtility uniswapV3PositionUtility = new UniswapV3PositionUtility{salt: salt}();
        console.log("UniswapV3PositionUtility deployed at:", address(uniswapV3PositionUtility));
        vm.stopBroadcast();
    }
}

// forge script script/deploy/oracles/UniswapV3PositionUtility.s.sol:DeployUniswapV3PositionUtility --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv --account supa_test_deployer
// forge script script/deploy/oracles/UniswapV3PositionUtility.s.sol:DeployUniswapV3PositionUtility --rpc-url $ARBITRUM_RPC_URL --broadcast --etherscan-api-key $ARBISCAN_API_KEY --verify -vvvv --account supa_deployer
// forge script script/deploy/oracles/UniswapV3PositionUtility.s.sol:DeployUniswapV3PositionUtility --rpc-url $BASE_RPC_URL --broadcast --etherscan-api-key $BASESCAN_API_KEY --verify -vvvv --account supa_deployer --with-gas-price 1000000