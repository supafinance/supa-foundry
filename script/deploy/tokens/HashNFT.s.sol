// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HashNFT} from "src/tokens/HashNFT.sol";

contract DeployHashNFT is Script {
    function run() external {
        address owner = vm.envAddress("OWNER");
        string memory uri = vm.envString("URI");
        uint256 salt = vm.envUint("HASH_NFT_SALT");
        vm.startBroadcast(owner);
        HashNFT hashNFT = new HashNFT{salt: bytes32(salt)}(uri);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/tokens/HashNFT.s.sol:DeployHashNFT --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --account supa_test_deployer
