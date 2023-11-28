# UniV3Oracle
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/oracles/UniV3Oracle.sol)

**Inherits:**
[ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md), [INFTValueOracle](/src/interfaces/INFTValueOracle.sol/interface.INFTValueOracle.md)


## State Variables
### manager

```solidity
INonfungiblePositionManager public immutable manager;
```


### factory

```solidity
IUniswapV3Factory public immutable factory;
```


### collateralFactor

```solidity
int256 collateralFactor = 1 ether;
```


### erc20ValueOracle

```solidity
mapping(address => IERC20ValueOracle) public erc20ValueOracle;
```


### Q96

```solidity
int256 constant Q96 = int256(FixedPoint96.Q96);
```


## Functions
### constructor


```solidity
constructor(address _factory, address _manager, address _owner) ImmutableGovernance(_owner);
```

### setERC20ValueOracle


```solidity
function setERC20ValueOracle(address token, address oracle) external onlyGovernance;
```

### setCollateralFactor


```solidity
function setCollateralFactor(int256 _collateralFactor) external onlyGovernance;
```

### getTokenAmounts


```solidity
function getTokenAmounts(uint256 tokenId) external view returns (int256 amount0, int256 amount1);
```

### calcValue


```solidity
function calcValue(uint256 tokenId) external view override returns (int256, int256);
```

