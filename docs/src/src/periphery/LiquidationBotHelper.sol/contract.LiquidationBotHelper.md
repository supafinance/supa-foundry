# LiquidationBotHelper
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/LiquidationBotHelper.sol)


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

### getRiskAdjustedPositionValuesBatch


```solidity
function getRiskAdjustedPositionValuesBatch(address[] calldata supaWallets)
    external
    view
    returns (ValuesStruct[] memory values);
```

## Structs
### ValuesStruct

```solidity
struct ValuesStruct {
    int256 totalValue;
    int256 collateral;
    int256 debt;
}
```

