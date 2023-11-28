# WETH9
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/external/WETH9.sol)

**Inherits:**
ERC20


## Functions
### constructor


```solidity
constructor() ERC20("Wrapped ETH", "WETH");
```

### deposit


```solidity
function deposit() external payable;
```

### withdraw


```solidity
function withdraw(uint256 amount) external;
```

### mint


```solidity
function mint(address to, uint256 amount) external;
```

