# MockERC20Oracle
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/MockERC20Oracle.sol)

**Inherits:**
[IERC20ValueOracle](/src/interfaces/IERC20ValueOracle.sol/interface.IERC20ValueOracle.md), [ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md)


## State Variables
### price

```solidity
int256 public price;
```


### collateralFactor

```solidity
int256 public collateralFactor = 1 ether;
```


### borrowFactor

```solidity
int256 public borrowFactor = 1 ether;
```


### tokenDecimals

```solidity
uint256 public tokenDecimals;
```


## Functions
### constructor


```solidity
constructor(address owner) ImmutableGovernance(owner);
```

### setPrice

Sets the oracle price


```solidity
function setPrice(int256 _price, uint256 _tokenDecimals, uint256) external onlyGovernance;
```

### setRiskFactors

Sets the risk factors (collateral factor & borrow factor)

*Emits a RiskFactorsSet event*


```solidity
function setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) external onlyGovernance;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collateralFactor`|`int256`|The new collateral factor|
|`_borrowFactor`|`int256`|The new borrow factor|


### calcValue


```solidity
function calcValue(int256 amount) external view override returns (int256 value, int256 riskAdjustedValue);
```

### getValues


```solidity
function getValues()
    external
    view
    override
    returns (int256 value, int256 collateralAdjustedValue, int256 borrowAdjustedValue);
```

