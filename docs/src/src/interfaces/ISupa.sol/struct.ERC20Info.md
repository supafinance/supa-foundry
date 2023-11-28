# ERC20Info
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/ISupa.sol)


```solidity
struct ERC20Info {
    address erc20Contract;
    IERC20ValueOracle valueOracle;
    ERC20Pool collateral;
    ERC20Pool debt;
    uint256 baseRate;
    uint256 slope1;
    uint256 slope2;
    uint256 targetUtilization;
    uint256 timestamp;
}
```

