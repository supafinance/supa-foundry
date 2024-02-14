// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GetTokenBalance is Script {
    function run() external {
        address walletAddress = 0x1f250e67A8D12D30E7605EeBC8bFdF7019D38cE0;

        IERC20 tokenAddress = IERC20(0xB0057C0DeAB7eBCf45B520de7645c93A547d6A37);

        uint256 balance = tokenAddress.balanceOf(walletAddress);
        console.log('balance:', balance);
    }
}

// forge script script/data/GetTokenBalance.s.sol:GetTokenBalance --rpc-url $BASE_RPC_URL --broadcast -vvvv

