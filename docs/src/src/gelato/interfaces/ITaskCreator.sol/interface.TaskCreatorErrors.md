# TaskCreatorErrors
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/interfaces/ITaskCreator.sol)


## Errors
### NotTaskOwner
Thrown when `msg.sender` is not the task owner


```solidity
error NotTaskOwner();
```

### NotSupaWallet
Thrown when `msg.sender` is not a supa wallet


```solidity
error NotSupaWallet();
```

### InsufficientPower
Thrown when `user` does not have enough power credits


```solidity
error InsufficientPower(address user);
```

### InsufficientUsdcBalance
Thrown when `user` does not have enough USDC


```solidity
error InsufficientUsdcBalance(address user);
```

### UsdcTransferFailed
Thrown when unable to transfer USDC


```solidity
error UsdcTransferFailed();
```

### Unauthorized
Thrown when `msg.sender` is not authorized


```solidity
error Unauthorized();
```

### UnauthorizedCID
Thrown when 'CID' is not authorized


```solidity
error UnauthorizedCID(string CID);
```

### TaskNotInsolvent
Thrown when attempting to cancel a solvent task not owned by the caller


```solidity
error TaskNotInsolvent(bytes32 taskId);
```

### AddressZero
Thrown when an input address is the zero address


```solidity
error AddressZero();
```

### TiersNotSet
Thrown when the power rate tiers are not set


```solidity
error TiersNotSet();
```

### InvalidPrice
Thrown when the gas price feed returns a zero or negative price


```solidity
error InvalidPrice();
```

