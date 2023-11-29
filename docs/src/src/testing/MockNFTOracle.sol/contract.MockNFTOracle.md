# MockNFTOracle
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/MockNFTOracle.sol)

**Inherits:**
[INFTValueOracle](/src/interfaces/INFTValueOracle.sol/interface.INFTValueOracle.md)


## State Variables
### prices

```solidity
mapping(uint256 => int256) prices;
```


### collateralFactor

```solidity
int256 collateralFactor = 1 ether;
```


## Functions
### setPrice


```solidity
function setPrice(uint256 tokenId, int256 price) external;
```

### setCollateralFactor


```solidity
function setCollateralFactor(int256 _collateralFactor) external;
```

### calcValue


```solidity
function calcValue(uint256 tokenId) external view override returns (int256, int256);
```

