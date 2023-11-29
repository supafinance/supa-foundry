# Governance
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/governance/Governance.sol)

**Inherits:**
[AccessControl](/src/lib/AccessControl.sol/contract.AccessControl.md), ERC1155Receiver


## State Variables
### voting

```solidity
address public voting;
```


### maxSupportedGasCost

```solidity
uint256 public maxSupportedGasCost = 8e6;
```


### bitmaskByAddressBySelector

```solidity
mapping(address => mapping(bytes4 => uint256)) public bitmaskByAddressBySelector;
```


## Functions
### constructor


```solidity
constructor(address _governanceProxy, address _hashNFT, address _voting) AccessControl(_governanceProxy, _hashNFT);
```

### executeBatch


```solidity
function executeBatch(CallWithoutValue[] memory calls) external;
```

### executeBatchWithClearance


```solidity
function executeBatchWithClearance(CallWithoutValue[] memory calls, uint8 accessLevel) external;
```

### transferVoting


```solidity
function transferVoting(address newVoting) external onlyGovernance;
```

### setAccessLevel


```solidity
function setAccessLevel(address addr, bytes4 selector, uint8 accessLevel, bool allowed) external onlyGovernance;
```

### setMaxSupportedGasCost


```solidity
function setMaxSupportedGasCost(uint256 _maxSupportedGasCost) external onlyGovernance;
```

### onERC1155Received


```solidity
function onERC1155Received(address, address, uint256, uint256, bytes calldata) external view returns (bytes4);
```

### onERC1155BatchReceived


```solidity
function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
    external
    view
    returns (bytes4);
```

### governanceProxy


```solidity
function governanceProxy() internal view returns (GovernanceProxy);
```

## Events
### ExecutionFailed

```solidity
event ExecutionFailed(uint256 indexed messageId, string reason);
```

### ExecutionSucceeded

```solidity
event ExecutionSucceeded(uint256 indexed messageId);
```

### MaxSupportedGasCostSet

```solidity
event MaxSupportedGasCostSet(uint256 indexed newMaxSupportedGasCost);
```

## Errors
### AccessDenied

```solidity
error AccessDenied(address account, uint8 accessLevel);
```

### InvalidCall

```solidity
error InvalidCall(address to, bytes callData);
```

### CallDenied

```solidity
error CallDenied(address to, bytes callData, uint8 accessLevel);
```

### PrivilagedMethod

```solidity
error PrivilagedMethod(address to, bytes4 selector);
```

### OnlyHashNFT

```solidity
error OnlyHashNFT();
```

### InsufficientGas

```solidity
error InsufficientGas();
```

