// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Voting} from "src/governance/Voting.sol";

contract InitCodeHashVoting is Script {
    function run() external {
        address hashNFTAddress = vm.envAddress("HASH_NFT_ADDRESS");
        address governanceTokenAddress = vm.envAddress("GOVERNANCE_TOKEN_ADDRESS");
        uint256 mappingSlot = vm.envUint("VOTING_MAPPING_SLOT");
        uint256 totalSupplySlot = vm.envUint("VOTING_TOTAL_SUPPLY_SLOT");
        address governanceAddress = vm.envAddress("GOVERNANCE_ADDRESS");

        // Encode the constructor arguments
        bytes memory encodedArgs =
            abi.encode(hashNFTAddress, governanceTokenAddress, mappingSlot, totalSupplySlot, governanceAddress);

        // Append the encoded arguments to the bytecode
        bytes memory bytecode = abi.encodePacked(type(Voting).creationCode, encodedArgs);

        // Calculate the hash
        bytes32 hash = keccak256(bytecode);
        console.logBytes32(hash);
    }
}

// forge script script/initCode/GovernanceProxy.s.sol:InitCodeHashGovernanceProxy --rpc-url $GOERLI_RPC_URL -vvvv
