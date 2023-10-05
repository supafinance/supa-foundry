// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";

import {SupaConfig} from "src/supa/SupaConfig.sol";

contract GetWalletNfts is Script {
    function run() external {
        address walletAddress = 0x282cD0b8b0b9c5ae65732E2C81E2d29cc63FDAA5;

        address supaAddress = vm.envAddress("SUPA");

        SupaConfig supaConfig = SupaConfig(supaAddress);
        SupaConfig.NFTData[] memory nftData = supaConfig.getCreditAccountERC721(walletAddress);

        for (uint256 i = 0; i < nftData.length; i++) {
            console.log("i", i);
            console.log(nftData[i].erc721);
            console.log(nftData[i].tokenId);
        }
    }
}

// forge script script/data/GetWalletNfts.s.sol:GetWalletNfts --rpc-url $GOERLI_RPC_URL --broadcast -vvvv