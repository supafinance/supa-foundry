// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GetTokenBalance is Script {
    function run() external {
        address walletAddress = 0x67B369866E376e532952F587D5ab84ad5033bB5E;

        IERC20 tokenAddress = IERC20(0x18e526F710B8d504A735927f5Eb8BdF2F4386811);

        uint256 balance = tokenAddress.balanceOf(walletAddress);
        console.log('balance:', balance);
    }
}

// forge script script/data/GetTokenBalance.s.sol:GetTokenBalance --rpc-url $GOERLI_RPC_URL --broadcast -vvvv

