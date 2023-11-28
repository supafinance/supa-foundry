# AutomateTaskCreator
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/AutomateTaskCreator.sol)

**Inherits:**
[AutomateReady](/src/gelato/AutomateReady.sol/abstract.AutomateReady.md)

*Inherit this contract to allow your smart contract
to be a task creator and create tasks.*


## State Variables
### gelato1Balance

```solidity
IGelato1Balance public constant gelato1Balance = IGelato1Balance(0x7506C12a824d73D9b08564d5Afc22c949434755e);
```


## Functions
### constructor


```solidity
constructor(address _automate, address _taskCreator) AutomateReady(_automate, _taskCreator);
```

### _depositFunds1Balance


```solidity
function _depositFunds1Balance(uint256 _amount, address _token, address _sponsor) internal;
```

### _createTask

*Only deposit ETH on goerli for now.*

*Only deposit USDC on polygon for now.*


```solidity
function _createTask(
    address _execAddress,
    bytes memory _execDataOrSelector,
    ModuleData memory _moduleData,
    address _feeToken
) internal returns (bytes32);
```

### _cancelTask


```solidity
function _cancelTask(bytes32 _taskId) internal;
```

### _resolverModuleArg


```solidity
function _resolverModuleArg(address _resolverAddress, bytes memory _resolverData)
    internal
    pure
    returns (bytes memory);
```

### _proxyModuleArg


```solidity
function _proxyModuleArg() internal pure returns (bytes memory);
```

### _singleExecModuleArg


```solidity
function _singleExecModuleArg() internal pure returns (bytes memory);
```

### _web3FunctionModuleArg


```solidity
function _web3FunctionModuleArg(string memory _web3FunctionHash, bytes memory _web3FunctionArgsHex)
    internal
    pure
    returns (bytes memory);
```

### _timeTriggerModuleArg


```solidity
function _timeTriggerModuleArg(uint128 _start, uint128 _interval) internal pure returns (bytes memory);
```

### _cronTriggerModuleArg


```solidity
function _cronTriggerModuleArg(string memory _expression) internal pure returns (bytes memory);
```

## Events
### TaskCancelled

```solidity
event TaskCancelled(bytes32 indexed taskId);
```

## Errors
### OnlyGoerli
*Only deposit ETH on goerli for now.*


```solidity
error OnlyGoerli();
```

