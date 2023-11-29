# ITaskCreator
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/interfaces/ITaskCreator.sol)

**Inherits:**
[TaskCreatorErrors](/src/gelato/interfaces/ITaskCreator.sol/interface.TaskCreatorErrors.md)


## Events
### TaskCreated
Emitted when a task is created


```solidity
event TaskCreated(bytes32 indexed taskId, address indexed taskOwner, uint256 automationId, string cid);
```

### PowerPurchased
Emitted when power is purchased


```solidity
event PowerPurchased(address indexed user, uint256 indexed powerCredits, uint256 usdcAmount);
```

### GasPaidWithCredits
Emitted when power is used to pay for gas


```solidity
event GasPaidWithCredits(address indexed user, uint256 indexed gasAmount, uint256 creditAmount);
```

### GasPaidNative

```solidity
event GasPaidNative(address indexed user, uint256 indexed gasAmount);
```

### AdminPowerIncrease
Emitted when power is given to a user by an admin


```solidity
event AdminPowerIncrease(address indexed user, uint256 indexed creditAmount);
```

### FeeTiersSet
Emitted when the fee tiers are set


```solidity
event FeeTiersSet(Tier[] tiers);
```

### FeeCollectorSet
Emitted when the fee collector is set


```solidity
event FeeCollectorSet(address feeCollector);
```

### DepositAmountSet
Emitted when the deposit amount is set


```solidity
event DepositAmountSet(uint256 depositAmount);
```

### PowerPerExecutionSet
Emitted when the power per execution is set


```solidity
event PowerPerExecutionSet(uint256 powerPerExecution);
```

### GasPriceFeedSet

```solidity
event GasPriceFeedSet(address gasPriceFeed);
```

## Structs
### Tier

```solidity
struct Tier {
    uint256 limit;
    uint256 rate;
}
```

### UserPowerData

```solidity
struct UserPowerData {
    uint256 lastUpdate;
    uint256 taskExecsPerSecond;
}
```

