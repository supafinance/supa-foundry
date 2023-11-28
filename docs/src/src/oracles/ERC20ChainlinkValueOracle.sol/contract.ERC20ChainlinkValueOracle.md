# ERC20ChainlinkValueOracle
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/oracles/ERC20ChainlinkValueOracle.sol)

**Inherits:**
[ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md), [IERC20ValueOracle](/src/interfaces/IERC20ValueOracle.sol/interface.IERC20ValueOracle.md)


## State Variables
### priceOracle

```solidity
AggregatorV3Interface public priceOracle;
```


### base

```solidity
int256 public immutable base;
```


### collateralFactor

```solidity
int256 public collateralFactor = 1 ether;
```


### borrowFactor

```solidity
int256 public borrowFactor = 1 ether;
```


## Functions
### checkDecimals


```solidity
modifier checkDecimals(string memory label, uint8 decimals);
```

### constructor


```solidity
constructor(
    address chainlink,
    uint8 baseDecimals,
    uint8 tokenDecimals,
    int256 _collateralFactor,
    int256 _borrowFactor,
    address _owner
)
    ImmutableGovernance(_owner)
    checkDecimals("baseDecimals", baseDecimals)
    checkDecimals("tokenDecimals", tokenDecimals);
```

### setRiskFactors

Set risk factors: collateral factor and borrow factor


```solidity
function setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) external onlyGovernance;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collateralFactor`|`int256`|Collateral factor|
|`_borrowFactor`|`int256`|Borrow factor|


### getRiskFactors


```solidity
function getRiskFactors() external view returns (int256, int256);
```

### calcValue


```solidity
function calcValue(int256 balance) external view override returns (int256 value, int256 riskAdjustedValue);
```

### getValues


```solidity
function getValues()
    external
    view
    override
    returns (int256 value, int256 collateralAdjustedValue, int256 borrowAdjustedValue);
```

### _setRiskFactors


```solidity
function _setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) internal;
```

