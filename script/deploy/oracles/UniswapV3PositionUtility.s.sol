// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniswapV3PositionUtility} from "src/oracles/UniswapV3PositionUtility.sol";

contract DeployUniswapV3PositionUtility is Script {
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

        bytes32 salt = 0x1234567890098765432112345678900987654321123456789009876543211234;

        vm.startBroadcast(deployer);
        new UniswapV3PositionUtility{salt: salt}();
        vm.stopBroadcast();
    }
}

// forge script script/deploy/oracles/UniswapV3PositionUtility.s.sol:DeployUniswapV3PositionUtility --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv --account supa_test_deployer
// forge script script/deploy/oracles/UniswapV3PositionUtility.s.sol:DeployUniswapV3PositionUtility --rpc-url $ARBITRUM_RPC_URL --broadcast --etherscan-api-key $ARBISCAN_API_KEY --verify -vvvv --account supa_deployer