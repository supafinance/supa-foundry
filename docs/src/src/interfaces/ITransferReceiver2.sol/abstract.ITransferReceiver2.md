# ITransferReceiver2
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/ITransferReceiver2.sol)


## Functions
### onTransferReceived2

*Called by a token to indicate a transfer into the callee*


```solidity
function onTransferReceived2(address operator, address from, Transfer[] calldata transfers, bytes calldata data)
    external
    virtual
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The account that initiated the transfer|
|`from`|`address`|The account that has sent the token|
|`transfers`|`Transfer[]`|Transfers that have been made|
|`data`|`bytes`|The extra data being passed to the receiving contract|


### onlyTransferAndCall2


```solidity
modifier onlyTransferAndCall2();
```

## Errors
### InvalidSender

```solidity
error InvalidSender(address sender);
```

## Structs
### Transfer

```solidity
struct Transfer {
    address token;
    uint256 amount;
}
```

