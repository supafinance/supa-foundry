# TestERC20
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/TestERC20.sol)

**Inherits:**
ERC20


## State Variables
### _decimals

```solidity
uint8 private immutable _decimals;
```


## Functions
### constructor


```solidity
constructor(string memory name, string memory symbol, uint8 deci) ERC20(name, symbol);
```

### mint


```solidity
function mint(address to, uint256 amount) external;
```

### decimals


```solidity
function decimals() public view virtual override returns (uint8);
```

