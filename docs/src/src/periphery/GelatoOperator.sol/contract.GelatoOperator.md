# GelatoOperator
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/GelatoOperator.sol)

This contract acts as the operator for Gelato automated tasks

*This contract must be set as an operator on the target Wallet*


## State Variables
### dedicatedSender

```solidity
address public immutable dedicatedSender;
```


## Functions
### constructor


```solidity
constructor(address _dedicatedSender);
```

### onlyDedicatedSender


```solidity
modifier onlyDedicatedSender();
```

### execute

Executes a batch of calls on a target contract

*This contract must be set as an operator on the target Wallet*


```solidity
function execute(WalletProxy _target, Call[] calldata _calls) external onlyDedicatedSender;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_target`|`WalletProxy`|The target Supa wallet|
|`_calls`|`Call[]`|The calls to execute|


### executeLink

Executes a batch of calls on a target contract

*This contract must be set as an operator on the target Wallet*


```solidity
function executeLink(WalletLogic _target, LinkedCall[] calldata _calls) external onlyDedicatedSender;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_target`|`WalletLogic`|The target Supa wallet|
|`_calls`|`LinkedCall[]`|The calls to execute|


## Errors
### OnlyDedicatedSender
Only the dedicated sender can call this function


```solidity
error OnlyDedicatedSender();
```

