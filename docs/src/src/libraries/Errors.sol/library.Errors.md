# Errors
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/libraries/Errors.sol)

Library containing all custom errors the protocol may revert with.


## Errors
### AddressZero
The address cannot be the zero address


```solidity
error AddressZero();
```

### InvalidSignature
The signature is invalid


```solidity
error InvalidSignature();
```

### ReceiverNotContract
The receiving address is not a contract


```solidity
error ReceiverNotContract();
```

### ReceiverNoImplementation
The receiver does not implement the required interface


```solidity
error ReceiverNoImplementation();
```

### WrongDataReturned
The receiver did not return the correct value - transaction failed


```solidity
error WrongDataReturned();
```

### NotApprovedOrOwner
Sender is not approved to spend wallet erc20


```solidity
error NotApprovedOrOwner();
```

### NotOwner
Sender is not the owner of the wallet;


```solidity
error NotOwner(address sender, address owner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The address of the sender|
|`owner`|`address`|The address of the owner|

### InsufficientAllowance
Transfer amount exceeds allowance


```solidity
error InsufficientAllowance();
```

### SelfApproval
Cannot approve self as spender


```solidity
error SelfApproval();
```

### NotNFT
Asset is not an NFT


```solidity
error NotNFT();
```

### NotNFTOwner
NFT must be owned the the user or user's wallet


```solidity
error NotNFTOwner();
```

### Insolvent
Operation leaves wallet insolvent


```solidity
error Insolvent();
```

### SolvencyCheckTooExpensive
Thrown if a wallet accumulates too many assets


```solidity
error SolvencyCheckTooExpensive();
```

### CannotWithdrawDebt
Cannot withdraw debt


```solidity
error CannotWithdrawDebt();
```

### NotLiquidatable
Wallet is not liquidatable


```solidity
error NotLiquidatable();
```

### InsufficientReserves
There are insufficient reserves in the protocol for the debt


```solidity
error InsufficientReserves();
```

### TokenStorageExceeded
This operation would add too many tokens to the credit account


```solidity
error TokenStorageExceeded();
```

### NotERC20
The address is not a registered ERC20


```solidity
error NotERC20();
```

### InvalidNewOwner
`newOwner` is not the proposed new owner


```solidity
error InvalidNewOwner(address proposedOwner, address newOwner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proposedOwner`|`address`|The address of the proposed new owner|
|`newOwner`|`address`|The address of the attempted new owner|

### OnlyWallet
Only wallet can call this function


```solidity
error OnlyWallet();
```

### WalletNonExistent
Recipient is not a valid wallet


```solidity
error WalletNonExistent();
```

### NotRegistered
Asset is not registered


```solidity
error NotRegistered(address token);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The unregistered asset|

### NotImplemented
Thrown when the function is unimplemented


```solidity
error NotImplemented();
```

### InvalidImplementation
The implementation must be a contract


```solidity
error InvalidImplementation();
```

### DeprecatedVersion
The version is deprecated


```solidity
error DeprecatedVersion();
```

### BugLevelTooHigh
The bug level is too high


```solidity
error BugLevelTooHigh();
```

### NoRecommendedVersion
Recommended Version does not exist


```solidity
error NoRecommendedVersion();
```

### VersionNotRegistered
version is not registered


```solidity
error VersionNotRegistered();
```

### InvalidStatus
Specified status is out of range


```solidity
error InvalidStatus();
```

### InvalidBugLevel
Specified bug level is out of range


```solidity
error InvalidBugLevel();
```

### InvalidVersionName
version name cannot be the empty string


```solidity
error InvalidVersionName();
```

### InvalidVersion
version is deprecated or has a bug


```solidity
error InvalidVersion();
```

### VersionAlreadyRegistered
version is already registered


```solidity
error VersionAlreadyRegistered();
```

### TransfersUnsorted

```solidity
error TransfersUnsorted();
```

### EthDoesntMatchWethTransfer

```solidity
error EthDoesntMatchWethTransfer();
```

### UnauthorizedOperator

```solidity
error UnauthorizedOperator(address operator, address from);
```

### ExpiredPermit

```solidity
error ExpiredPermit();
```

