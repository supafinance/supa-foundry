# OracleLibrary
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/oracles/libraries/OracleLibrary.sol)

Provides functions to integrate with V3 pool oracle


## Functions
### getQuoteAtTick

Given a tick and a token amount, calculates the amount of token received in exchange


```solidity
function getQuoteAtTick(int24 tick, uint128 baseAmount, address baseToken, address quoteToken)
    internal
    pure
    returns (uint256 quoteAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tick`|`int24`|Tick value used to calculate the quote|
|`baseAmount`|`uint128`|Amount of token to be converted|
|`baseToken`|`address`|Address of an ERC20 token contract used as the baseAmount denomination|
|`quoteToken`|`address`|Address of an ERC20 token contract used as the quoteAmount denomination|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`quoteAmount`|`uint256`|Amount of quoteToken received for baseAmount of baseToken|


### getOldestObservationSecondsAgo

Given a pool, it returns the number of seconds ago of the oldest stored observation


```solidity
function getOldestObservationSecondsAgo(address pool) internal view returns (uint32 secondsAgo);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`pool`|`address`|Address of Uniswap V3 pool that we want to observe|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`secondsAgo`|`uint32`|The number of seconds ago of the oldest observation stored for the pool|


### getChainedPrice

Returns the "synthetic" tick which represents the price of the first entry in `tokens` in terms of the last

*Useful for calculating relative prices along routes.*

*There must be one tick for each pairwise set of tokens.*


```solidity
function getChainedPrice(address[] memory tokens, int24[] memory ticks) internal pure returns (int256 syntheticTick);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokens`|`address[]`|The token contract addresses|
|`ticks`|`int24[]`|The ticks, representing the price of each token pair in `tokens`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`syntheticTick`|`int256`|The synthetic tick, representing the relative price of the outermost tokens in `tokens`|


## Structs
### WeightedTickData
Information for calculating a weighted arithmetic mean tick


```solidity
struct WeightedTickData {
    int24 tick;
    uint128 weight;
}
```

