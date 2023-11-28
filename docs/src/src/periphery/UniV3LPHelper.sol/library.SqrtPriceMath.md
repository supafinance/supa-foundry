# SqrtPriceMath
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/UniV3LPHelper.sol)

Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas


## Functions
### getAmount0Delta

Gets the amount0 delta between two prices

*Calculates liquidity / sqrt(lower) - liquidity / sqrt(upper),
i.e. liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))*


```solidity
function getAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity, bool roundUp)
    internal
    pure
    returns (uint256 amount0);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price|
|`sqrtRatioBX96`|`uint160`|Another sqrt price|
|`liquidity`|`uint128`|The amount of usable liquidity|
|`roundUp`|`bool`|Whether to round the amount up or down|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`uint256`|Amount of token0 required to cover a position of size liquidity between the two passed prices|


### getAmount1Delta

Gets the amount1 delta between two prices

*Calculates liquidity * (sqrt(upper) - sqrt(lower))*


```solidity
function getAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity, bool roundUp)
    internal
    pure
    returns (uint256 amount1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price|
|`sqrtRatioBX96`|`uint160`|Another sqrt price|
|`liquidity`|`uint128`|The amount of usable liquidity|
|`roundUp`|`bool`|Whether to round the amount up, or down|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount1`|`uint256`|Amount of token1 required to cover a position of size liquidity between the two passed prices|


### getAmount0Delta

Helper that gets signed token0 delta


```solidity
function getAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity)
    internal
    pure
    returns (int256 amount0);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price|
|`sqrtRatioBX96`|`uint160`|Another sqrt price|
|`liquidity`|`int128`|The change in liquidity for which to compute the amount0 delta|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount0`|`int256`|Amount of token0 corresponding to the passed liquidityDelta between the two prices|


### getAmount1Delta

Helper that gets signed token1 delta


```solidity
function getAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity)
    internal
    pure
    returns (int256 amount1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sqrtRatioAX96`|`uint160`|A sqrt price|
|`sqrtRatioBX96`|`uint160`|Another sqrt price|
|`liquidity`|`int128`|The change in liquidity for which to compute the amount1 delta|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount1`|`int256`|Amount of token1 corresponding to the passed liquidityDelta between the two prices|


