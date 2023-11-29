# IAutomate
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/Types.sol)


## Functions
### createTask


```solidity
function createTask(
    address execAddress,
    bytes calldata execDataOrSelector,
    ModuleData calldata moduleData,
    address feeToken
) external returns (bytes32 taskId);
```

### cancelTask


```solidity
function cancelTask(bytes32 taskId) external;
```

### getFeeDetails


```solidity
function getFeeDetails() external view returns (uint256, address);
```

### gelato


```solidity
function gelato() external view returns (address payable);
```

### taskModuleAddresses


```solidity
function taskModuleAddresses(Module) external view returns (address);
```

