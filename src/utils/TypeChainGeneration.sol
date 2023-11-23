// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// These unfortunately don't compile due to conflict with our version of openzeppelin
// import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
// import "@uniswap/v3-periphery/contracts/interfaces/INonfungibleTokenPositionDescriptor.sol";

// Just here so solidity compiles and typechain generates the types
