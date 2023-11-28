# OffchainEntityProxy
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/governance/OffchainEntityProxy.sol)

**Inherits:**
Ownable, EIP712


## State Variables
### TAKEOWNERSHIP_TYPEHASH

```solidity
bytes32 private constant TAKEOWNERSHIP_TYPEHASH = keccak256("TakeOwnership(address newOwner,uint256 nonce)");
```


### entityName

```solidity
bytes32 private immutable entityName;
```


### nonce

```solidity
uint256 public nonce;
```


## Functions
### constructor


```solidity
constructor(address offchainSigner, string memory _entityName) EIP712("OffchainEntityProxy", "1");
```

### takeOwnership

Take ownership of this contract.

*By using signature based ownership transfer, we can ensure that the signer can be*

*purely offchain.*


```solidity
function takeOwnership(bytes calldata signature) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`signature`|`bytes`|Signature of the owner to be.|


### executeBatch

Execute a batch of contract calls.

*Allow the owner to execute arbitrary calls on behalf of the entity through this proxy*

*contract.*


```solidity
function executeBatch(Call[] memory calls) external payable onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|An array of calls to execute.|


### name

Get the name of the entity.


```solidity
function name() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The name of the entity.|


## Errors
### InvalidSignature

```solidity
error InvalidSignature();
```

