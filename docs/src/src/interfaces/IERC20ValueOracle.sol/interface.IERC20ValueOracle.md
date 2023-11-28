# IERC20ValueOracle
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/IERC20ValueOracle.sol)


## Functions
### collateralFactor


```solidity
function collateralFactor() external view returns (int256 collateralFactor);
```

### borrowFactor


```solidity
function borrowFactor() external view returns (int256 borrowFactor);
```

### calcValue


```solidity
function calcValue(int256 balance) external view returns (int256 value, int256 riskAdjustedValue);
```

### getValues


```solidity
function getValues() external view returns (int256 value, int256 collateralAdjustedValue, int256 borrowAdjustedValue);
```

## Events
### RiskFactorsSet
Emitted when risk factors are set


```solidity
event RiskFactorsSet(int256 indexed collateralFactor, int256 indexed borrowFactor);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collateralFactor`|`int256`|Collateral factor|
|`borrowFactor`|`int256`|Borrow factor|

