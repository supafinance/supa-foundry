# TransferAndCall2
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/supa/TransferAndCall2.sol)

**Inherits:**
IERC1363Receiver, EIP712


## State Variables
### TRANSFER_TYPESTRING

```solidity
bytes private constant TRANSFER_TYPESTRING = "Transfer(address token,uint256 amount)";
```


### PERMIT_TYPESTRING

```solidity
bytes private constant PERMIT_TYPESTRING =
    "Permit(address receiver,Transfer[] transfers,bytes data,uint256 nonce,uint256 deadline)";
```


### TRANSFER_TYPEHASH

```solidity
bytes32 private constant TRANSFER_TYPEHASH = keccak256(TRANSFER_TYPESTRING);
```


### PERMIT_TYPEHASH

```solidity
bytes32 private constant PERMIT_TYPEHASH = keccak256(abi.encodePacked(PERMIT_TYPESTRING, TRANSFER_TYPESTRING));
```


### approvalByOwnerByOperator

```solidity
mapping(address => mapping(address => bool)) public approvalByOwnerByOperator;
```


### nonceMap

```solidity
mapping(address => NonceMap) private nonceMap;
```


## Functions
### constructor


```solidity
constructor() EIP712("TransferAndCall2", "1");
```

### setApprovalForAll

*Set approval for all token transfers from msg.sender to a particular operator*


```solidity
function setApprovalForAll(address operator, bool approved) external;
```

### transferAndCall2

*Called by a token to indicate a transfer into the callee*


```solidity
function transferAndCall2(address receiver, ITransferReceiver2.Transfer[] calldata transfers, bytes calldata data)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The account to sent the tokens|
|`transfers`|`ITransferReceiver2.Transfer[]`|Transfers that have been made|
|`data`|`bytes`|The extra data being passed to the receiving contract|


### transferAndCall2WithValue

*Called by a token to indicate a transfer into the callee, converting ETH to WETH*


```solidity
function transferAndCall2WithValue(
    address receiver,
    address weth,
    ITransferReceiver2.Transfer[] calldata transfers,
    bytes calldata data
) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The account to sent the tokens|
|`weth`|`address`|The WETH9 contract address|
|`transfers`|`ITransferReceiver2.Transfer[]`|Transfers that have been made|
|`data`|`bytes`|The extra data being passed to the receiving contract|


### transferFromAndCall2

*Called by a token to indicate a transfer into the callee*


```solidity
function transferFromAndCall2(
    address from,
    address receiver,
    ITransferReceiver2.Transfer[] calldata transfers,
    bytes calldata data
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The account that has sent the tokens|
|`receiver`|`address`|The account to sent the tokens|
|`transfers`|`ITransferReceiver2.Transfer[]`|Transfers that have been made|
|`data`|`bytes`|The extra data being passed to the receiving contract|


### transferAndCall2WithPermit


```solidity
function transferAndCall2WithPermit(
    address from,
    address receiver,
    ITransferReceiver2.Transfer[] calldata transfers,
    bytes calldata data,
    uint256 nonce,
    uint256 deadline,
    bytes calldata signature
) external;
```

### onTransferReceived

Callback for ERC1363 transferAndCall


```solidity
function onTransferReceived(address _operator, address _from, uint256 _amount, bytes calldata _data)
    external
    override
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_operator`|`address`|The address which called `transferAndCall` function|
|`_from`|`address`|The address which previously owned the token|
|`_amount`|`uint256`|The amount of tokens being transferred|
|`_data`|`bytes`|Additional data containing the receiver address and the extra data|


### _transferFromAndCall2Impl


```solidity
function _transferFromAndCall2Impl(
    address from,
    address receiver,
    address weth,
    ITransferReceiver2.Transfer[] calldata transfers,
    bytes memory data
) internal;
```

### _callOnTransferReceived2


```solidity
function _callOnTransferReceived2(
    address to,
    address operator,
    address from,
    ITransferReceiver2.Transfer[] memory transfers,
    bytes memory data
) internal;
```

## Errors
### onTransferReceivedFailed

```solidity
error onTransferReceivedFailed(
    address to, address operator, address from, ITransferReceiver2.Transfer[] transfers, bytes data
);
```

