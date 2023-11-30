// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract DeployUniV3Oracle is Script {
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
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address owner = vm.envAddress("DEPLOYER");

        bytes32 salt = 0x1234567890123456789012345678901234567890123456789012345678901234;

        vm.startBroadcast(deployer);
        new UniV3Oracle{salt: salt}(factory, manager, owner);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/oracles/UniV3Oracle.s.sol:DeployUniV3Oracle --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv --account supa_test_deployer
