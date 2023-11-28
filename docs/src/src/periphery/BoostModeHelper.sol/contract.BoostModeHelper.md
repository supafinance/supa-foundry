# BoostModeHelper
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/BoostModeHelper.sol)


## State Variables
### supa

```solidity
ISupa public immutable supa;
```


## Functions
### constructor


```solidity
constructor(address _supa);
```

### getMaxBorrowable


```solidity
function getMaxBorrowable(
    address supaWallet,
    IERC20 erc20,
    address valueOracle,
    int256 borrowedAmountUsd,
    uint8 decimals
)
    external
    view
    returns (int256 maxBorrowableUsd, int256 maxBorrowableToken, uint256 accountRisk, int256 collateral, int256 debt);
```

