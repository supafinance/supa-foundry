# IOpsProxy
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/interfaces/IOpsProxy.sol)


## Functions
### batchExecuteCall

Multicall to different contracts with different datas.


```solidity
function batchExecuteCall(address[] calldata targets, bytes[] calldata datas, uint256[] calldata values)
    external
    payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`targets`|`address[]`|Addresses of contracts to be called.|
|`datas`|`bytes[]`|Datas for each contract call.|
|`values`|`uint256[]`|Native token value for each contract call.|


### executeCall

Call to a single contract.


```solidity
function executeCall(address target, bytes calldata data, uint256 value) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Address of contracts to be called.|
|`data`|`bytes`|Data for contract call.|
|`value`|`uint256`|Native token value for contract call.|


### ops


```solidity
function ops() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address Ops smart contract address|


### owner


```solidity
function owner() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address Owner of the proxy|


### version


```solidity
function version() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 version of OpsProxy.|


## Events
### ExecuteCall
Emitted when proxy calls a contract successfully in `executeCall`


```solidity
event ExecuteCall(address indexed target, bytes data, uint256 value, bytes returnData);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|Address of contract that is called|
|`data`|`bytes`|Data used in the call.|
|`value`|`uint256`|Native token value used in the call.|
|`returnData`|`bytes`|Data returned by the call.|

