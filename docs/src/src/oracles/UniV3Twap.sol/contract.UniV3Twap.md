# UniV3Twap
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/oracles/UniV3Twap.sol)


## Functions
### getSqrtTwapX96


```solidity
function getSqrtTwapX96(address uniswapV3Pool, uint32 twapInterval) public view returns (uint160 sqrtPriceX96);
```

### getPriceX96FromSqrtPriceX96


```solidity
function getPriceX96FromSqrtPriceX96(uint160 sqrtPriceX96) public pure returns (uint256 priceX96);
```

