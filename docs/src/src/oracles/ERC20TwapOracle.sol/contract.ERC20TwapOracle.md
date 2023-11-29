# ERC20TwapOracle
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/oracles/ERC20TwapOracle.sol)

**Inherits:**
[ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md), [IERC20ValueOracle](/src/interfaces/IERC20ValueOracle.sol/interface.IERC20ValueOracle.md)


## State Variables
### poolAddress

```solidity
address public immutable poolAddress;
```


### isInverse

```solidity
bool public immutable isInverse;
```


### collateralFactor

```solidity
int256 public collateralFactor = 1 ether;
```


### borrowFactor

```solidity
int256 public borrowFactor = 1 ether;
```


### twapInterval

```solidity
uint32 public twapInterval = 300;
```


## Functions
### constructor


```solidity
constructor(address _poolAddress, bool _isInverse, address _owner) ImmutableGovernance(_owner);
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

### getRiskFactors


```solidity
function getRiskFactors() external view returns (int256, int256);
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


### setTwapInterval


```solidity
function setTwapInterval(uint32 _twapInterval) external onlyGovernance;
```

### getSqrtTwapX96


```solidity
function getSqrtTwapX96(address _uniswapV3Pool, uint32 _twapInterval) public view returns (uint160 sqrtPriceX96);
```

### getPriceX96FromSqrtPriceX96


```solidity
function getPriceX96FromSqrtPriceX96(uint160 sqrtPriceX96) public pure returns (uint256 priceX96);
```

### _setRiskFactors


```solidity
function _setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) internal;
```

## Errors
### InvalidBorrowFactor
Borrow factor must be greater than zero


```solidity
error InvalidBorrowFactor();
```

