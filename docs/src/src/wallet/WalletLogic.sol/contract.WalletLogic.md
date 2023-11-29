# WalletLogic
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/wallet/WalletLogic.sol)

**Inherits:**
[ImmutableVersion](/src/lib/ImmutableVersion.sol/contract.ImmutableVersion.md), IERC721Receiver, IERC1271, [ITransferReceiver2](/src/interfaces/ITransferReceiver2.sol/abstract.ITransferReceiver2.md), EIP712, [IWallet](/src/interfaces/IWallet.sol/interface.IWallet.md), [IERC1363SpenderExtended](/src/interfaces/IERC1363-extended.sol/interface.IERC1363SpenderExtended.md)


## State Variables
### EXECUTEBATCH_TYPESTRING

```solidity
bytes private constant EXECUTEBATCH_TYPESTRING = "ExecuteBatch(Call[] calls,uint256 nonce,uint256 deadline)";
```


### TRANSFER_TYPESTRING

```solidity
bytes private constant TRANSFER_TYPESTRING = "Transfer(address token,uint256 amount)";
```


### ONTRANSFERRECEIVED2CALL_TYPESTRING

```solidity
bytes private constant ONTRANSFERRECEIVED2CALL_TYPESTRING =
    "OnTransferReceived2Call(address operator,address from,Transfer[] transfers,Call[] calls,uint256 nonce,uint256 deadline)";
```


### EXECUTEBATCH_TYPEHASH

```solidity
bytes32 private constant EXECUTEBATCH_TYPEHASH =
    keccak256(abi.encodePacked(EXECUTEBATCH_TYPESTRING, CallLib.CALL_TYPESTRING));
```


### TRANSFER_TYPEHASH

```solidity
bytes32 private constant TRANSFER_TYPEHASH = keccak256(TRANSFER_TYPESTRING);
```


### ONTRANSFERRECEIVED2CALL_TYPEHASH

```solidity
bytes32 private constant ONTRANSFERRECEIVED2CALL_TYPEHASH =
    keccak256(abi.encodePacked(ONTRANSFERRECEIVED2CALL_TYPESTRING, CallLib.CALL_TYPESTRING, TRANSFER_TYPESTRING));
```


### VERSION

```solidity
string public constant VERSION = "1.3.2";
```


### forwardNFT

```solidity
bool internal forwardNFT;
```


### nonceMap

```solidity
NonceMap private nonceMap;
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner();
```

### onlyOwnerOrOperator


```solidity
modifier onlyOwnerOrOperator();
```

### onlyThisAddress


```solidity
modifier onlyThisAddress();
```

### onlySupa


```solidity
modifier onlySupa();
```

### constructor


```solidity
constructor() EIP712("Supa wallet", VERSION) ImmutableVersion(VERSION);
```

### transfer

Transfer ETH


```solidity
function transfer(address to, uint256 value) external payable onlyThisAddress;
```

### executeBatch

makes a batch of different calls from the name of wallet owner. Eventual state of
creditAccount and Supa must be solvent, i.e. debt on creditAccount cannot exceed collateral on
creditAccount and wallet and Supa reserve/debt must be sufficient

*- this goes to supa.executeBatch that would immediately call WalletProxy.executeBatch
from above of this file*


```solidity
function executeBatch(Call[] calldata calls) external payable onlyOwnerOrOperator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|{address to, bytes callData, uint256 value}[], where * to - is the address of the contract whose function should be called * callData - encoded function name and it's arguments * value - the amount of ETH to sent with the call|


### executeSignedBatch


```solidity
function executeSignedBatch(Call[] memory calls, uint256 nonce, uint256 deadline, bytes calldata signature)
    external
    payable;
```

### forwardNFTs


```solidity
function forwardNFTs(bool _forwardNFT) external;
```

### onERC721Received

ERC721 transfer callback

*it's a callback, required to be implemented by IERC721Receiver interface for the
contract to be able to receive ERC721 NFTs.
we are already using it to support "forwardNFT" of wallet.
`return this.onERC721Received.selector;` is mandatory part for the NFT transfer to work -
not a part of owr business logic*


```solidity
function onERC721Received(address, address, uint256 tokenId, bytes memory data)
    public
    virtual
    override
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`||
|`<none>`|`address`||
|`tokenId`|`uint256`|The NFT identifier which is being transferred|
|`data`|`bytes`|Additional data with no specified format|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|`bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`|


### setNonce


```solidity
function setNonce(uint256 nonce) external onlyOwner;
```

### onTransferReceived2

*Called by a token to indicate a transfer into the callee*


```solidity
function onTransferReceived2(
    address operator,
    address from,
    ITransferReceiver2.Transfer[] calldata transfers,
    bytes calldata data
) external override onlyTransferAndCall2 returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The account that initiated the transfer|
|`from`|`address`|The account that has sent the token|
|`transfers`|`ITransferReceiver2.Transfer[]`|Transfers that have been made|
|`data`|`bytes`|The extra data being passed to the receiving contract|


### onApprovalReceived


```solidity
function onApprovalReceived(address sender, uint256 amount, Call memory call) external onlySupa returns (bytes4);
```

### owner


```solidity
function owner() external view returns (address);
```

### isValidSignature

Returns whether the provided signature is valid for the provided data

*MUST return the bytes4 magic value 0x1626ba7e when function passes.
MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5).
MUST allow external calls.*


```solidity
function isValidSignature(bytes32 hash, bytes memory signature) public view override returns (bytes4 magicValue);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`hash`|`bytes32`|Hash of the data to be signed|
|`signature`|`bytes`|Signature byte array associated with _data|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`magicValue`|`bytes4`|The bytes4 magic value 0x1626ba7e|


### valueNonce


```solidity
function valueNonce(uint256 nonce) external view returns (bool);
```

### executeBatchLink

Execute a batch of calls with linked return values.


```solidity
function executeBatchLink(LinkedCall[] memory linkedCalls) external payable onlyOwnerOrOperator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`linkedCalls`|`LinkedCall[]`|The calls to execute.|


### _supa


```solidity
function _supa() internal view returns (ISupa);
```

## Errors
### InvalidData
Data does not match the expected format


```solidity
error InvalidData();
```

### InvalidSignature
Signature is invalid


```solidity
error InvalidSignature();
```

### NonceAlreadyUsed
Nonce has already been used


```solidity
error NonceAlreadyUsed();
```

### DeadlineExpired
Deadline has expired


```solidity
error DeadlineExpired();
```

### OnlySupa
Only Supa can call this function


```solidity
error OnlySupa();
```

### NotOwnerOrOperator
Only the owner or operator can call this function


```solidity
error NotOwnerOrOperator();
```

### OnlyOwner
Only the owner can call this function


```solidity
error OnlyOwner();
```

### OnlyThisAddress
Only this address can call this function


```solidity
error OnlyThisAddress();
```

### Insolvent
The wallet is insolvent


```solidity
error Insolvent();
```

### TransferFailed
Transfer failed


```solidity
error TransferFailed();
```

