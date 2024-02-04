// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VersionManager} from "src/supa/VersionManager.sol";

contract DeployVersionManager is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161 || chainId == 8453) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }

        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        bytes32 salt = vm.envBytes32("VERSION_MANAGER_SALT");
        vm.startBroadcast(deployer);
        VersionManager versionManager = new VersionManager{salt: salt}(governanceProxyAddress);
        vm.stopBroadcast();
        assert(address(versionManager) == vm.envAddress("VERSION_MANAGER_ADDRESS"));
    }
}

// cast create2 --init-code-hash $VERSION_MANAGER_INIT_CODE_HASH --starts-with 0x00000000

// forge script script/deploy/supa/VersionManager.s.sol:DeployVersionManager --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer

// forge script script/deploy/supa/VersionManager.s.sol:DeployVersionManager --rpc-url $ARBITRUM_RPC_URL --broadcast --verify -vvvv --account supa_deployer -g 100

// forge script script/deploy/supa/VersionManager.s.sol:DeployVersionManager --rpc-url $BASE_RPC_URL --broadcast --verify -vvvv --account supa_deployer --etherscan-api-key $BASESCAN_API_KEY