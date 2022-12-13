// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "../lib/ImmutableOwnable.sol";
import "../interfaces/IERC20ValueOracle.sol";
import "../lib/FsMath.sol";
import "../lib/FsUtils.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract UniV2Oracle is ImmutableOwnable, IERC20ValueOracle {
    IUniswapV2Factory public immutable factory;

    mapping(address => IERC20ValueOracle) public erc20ValueOracle;

    constructor(address _factory, address _manager, address _owner) ImmutableOwnable(_owner) {
        factory = IUniswapV2Factory(_factory);
    }
}