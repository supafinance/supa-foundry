# UnsafeMath
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/UniV3LPHelper.sol)

Contains methods that perform common math functions but do not do any overflow or underflow checks


## Functions
### divRoundingUp

Returns ceil(x / y)

*division by 0 has unspecified behavior, and must be checked externally*


```solidity
function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|The dividend|
|`y`|`uint256`|The divisor|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`z`|`uint256`|The quotient, ceil(x / y)|


