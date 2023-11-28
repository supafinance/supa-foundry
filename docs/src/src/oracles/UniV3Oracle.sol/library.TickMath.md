# TickMath
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/oracles/UniV3Oracle.sol)


## State Variables
### MIN_TICK
*The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128*


```solidity
int24 internal constant MIN_TICK = -887272;
```


### MAX_TICK
*The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128*


```solidity
int24 internal constant MAX_TICK = -MIN_TICK;
```


### MIN_SQRT_RATIO
*The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)*


```solidity
uint160 internal constant MIN_SQRT_RATIO = 4295128739;
```


### MAX_SQRT_RATIO
*The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)*


```solidity
uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
```


## Functions
### getSqrtRatioAtTick

Calculates sqrt(1.0001^tick) * 2^96

*Throws if |tick| > max tick*


```solidity
function getSqrtRatioAtTick(int24 tick) internal pure returns (int256 sqrtPriceX96);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tick`|`int24`|The input tick for the above formula|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`sqrtPriceX96`|`int256`|A Fixed point Q64.96 number representing the sqrt of the ratio of the two erc20s (token1/token0) at the given tick|


