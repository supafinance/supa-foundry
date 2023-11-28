# ISupaCore
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/ISupa.sol)


## Functions
### depositERC20ForWallet

top up the creditAccount owned by wallet `to` with `amount` of `erc20`


```solidity
function depositERC20ForWallet(address erc20, address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|Address of the ERC20 token to be transferred|
|`to`|`address`|Address of the wallet that creditAccount should be top up|
|`amount`|`uint256`|The amount of `erc20` to be sent|


### depositERC20

deposit `amount` of `erc20` to creditAccount from wallet


```solidity
function depositERC20(IERC20 erc20, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`IERC20`|Address of the ERC20 token to be transferred|
|`amount`|`uint256`|The amount of `erc20` to be transferred|


### withdrawERC20

deposit `amount` of `erc20` from creditAccount to wallet


```solidity
function withdrawERC20(IERC20 erc20, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`IERC20`|Address of the ERC20 token to be transferred|
|`amount`|`uint256`|The amount of `erc20` to be transferred|


### depositFull

deposit all `erc20s` from wallet to creditAccount


```solidity
function depositFull(IERC20[] calldata erc20s) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20s`|`IERC20[]`|Array of addresses of ERC20 to be transferred|


### withdrawFull

withdraw all `erc20s` from creditAccount to wallet


```solidity
function withdrawFull(IERC20[] calldata erc20s) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20s`|`IERC20[]`|Array of addresses of ERC20 to be transferred|


### depositERC721

deposit ERC721 `erc721Contract` token `tokenId` from wallet to creditAccount

*the part when we track the ownership of deposit NFT to a specific creditAccount is in
`onERC721Received` function of this contract*


```solidity
function depositERC721(address erc721Contract, uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721Contract`|`address`|The address of the ERC721 contract that the token belongs to|
|`tokenId`|`uint256`|The id of the token to be transferred|


### depositERC721ForWallet

deposit ERC721 `erc721Contract` token `tokenId` from wallet to creditAccount

*the part when we track the ownership of deposit NFT to a specific creditAccount is in
`onERC721Received` function of this contract*


```solidity
function depositERC721ForWallet(address erc721Contract, address to, uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721Contract`|`address`|The address of the ERC721 contract that the token belongs to|
|`to`|`address`|The wallet address for which the NFT will be deposited|
|`tokenId`|`uint256`|The id of the token to be transferred|


### withdrawERC721

withdraw ERC721 `nftContract` token `tokenId` from creditAccount to wallet


```solidity
function withdrawERC721(address erc721, uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721`|`address`|The address of the ERC721 contract that the token belongs to|
|`tokenId`|`uint256`|The id of the token to be transferred|


### transferERC20

transfer `amount` of `erc20` from creditAccount of caller wallet to creditAccount of `to` wallet


```solidity
function transferERC20(IERC20 erc20, address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`IERC20`|Address of the ERC20 token to be transferred|
|`to`|`address`|wallet address, whose creditAccount is the transfer target|
|`amount`|`uint256`|The amount of `erc20` to be transferred|


### transferERC721

transfer NFT `erc721` token `tokenId` from creditAccount of caller wallet to creditAccount of
`to` wallet


```solidity
function transferERC721(address erc721, uint256 tokenId, address to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721`|`address`|The address of the ERC721 contract that the token belongs to|
|`tokenId`|`uint256`|The id of the token to be transferred|
|`to`|`address`|wallet address, whose creditAccount is the transfer target|


### transferFromERC20

Transfer ERC20 tokens from creditAccount to another creditAccount

*Note: Allowance must be set with approveERC20*


```solidity
function transferFromERC20(address erc20, address from, address to, uint256 amount) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The index of the ERC20 token in erc20Infos array|
|`from`|`address`|The address of the wallet to transfer from|
|`to`|`address`|The address of the wallet to transfer to|
|`amount`|`uint256`|The amount of tokens to transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true, when the transfer has been successfully finished without been reverted|


### transferFromERC721

Transfer ERC721 tokens from creditAccount to another creditAccount


```solidity
function transferFromERC721(address collection, address from, address to, uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The address of the ERC721 token|
|`from`|`address`|The address of the wallet to transfer from|
|`to`|`address`|The address of the wallet to transfer to|
|`tokenId`|`uint256`|The id of the token to transfer|


### liquidate

Liquidate an undercollateralized position

*if creditAccount of `wallet` has more debt then collateral then this function will
transfer all debt and collateral ERC20s and ERC721 from creditAccount of `wallet` to creditAccount of
caller. Considering that market price of collateral is higher then market price of debt,
a friction of that difference would be sent back to liquidated creditAccount in Supa base currency.
More specific - "some fraction" is `liqFraction` parameter of Supa.
Considering that call to this function would create debt on caller (debt is less then
gains, yet still), consider using `liquify` instead, that would liquidate and use
obtained assets to cover all created debt
If creditAccount of `wallet` has less debt then collateral then the transaction will be reverted*


```solidity
function liquidate(address wallet) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of wallet whose creditAccount to be liquidate|


### approveAndCall

Approve an array of tokens and then call `onApprovalReceived` on msg.sender


```solidity
function approveAndCall(Approval[] calldata approvals, address spender, bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`approvals`|`Approval[]`|An array of ERC20 tokens with amounts, or ERC721 contracts with tokenIds|
|`spender`|`address`|The address of the spender|
|`data`|`bytes`|Additional data with no specified format, sent in call to `spender`|


### addOperator

Add an operator for wallet

*Operator can execute batch of transactions on behalf of wallet owner*


```solidity
function addOperator(address operator) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address of the operator to add|


### removeOperator

Remove an operator for wallet

*Operator can execute batch of transactions on behalf of wallet owner*


```solidity
function removeOperator(address operator) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address of the operator to remove|


### migrateWallet

Used to migrate wallet to this Supa contract


```solidity
function migrateWallet(address wallet, address owner, address implementation) external;
```

### executeBatch

Execute a batch of calls

*execute a batch of commands on Supa from the name of wallet owner. Eventual state of
creditAccount and Supa must be solvent, i.e. debt on creditAccount cannot exceed collateral
and Supa reserve/debt must be sufficient*


```solidity
function executeBatch(Call[] memory calls) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|An array of transaction calls|


### getApproved

Returns the approved address for a token, or zero if no address set


```solidity
function getApproved(address collection, uint256 tokenId) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The address of the ERC721 token|
|`tokenId`|`uint256`|The id of the token to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The wallet address that is allowed to transfer the ERC721 token|


### getRiskAdjustedPositionValues

returns the collateral, debt and total value of `walletAddress`.

*Notice that both collateral and debt has some coefficients on the actual amount of deposit
and loan assets! E.g.
for a deposit of 1 ETH the collateral would be equivalent to like 0.8 ETH, and
for a loan of 1 ETH the debt would be equivalent to like 1.2 ETH.
At the same time, totalValue is the unmodified difference between deposits and loans.*


```solidity
function getRiskAdjustedPositionValues(address walletAddress)
    external
    view
    returns (int256 totalValue, int256 collateral, int256 debt);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`walletAddress`|`address`|The address of wallet whose collateral, debt and total value would be returned|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValue`|`int256`|The difference between equivalents of deposit and loan assets|
|`collateral`|`int256`|The sum of deposited assets multiplied by their collateral factors|
|`debt`|`int256`|The sum of borrowed assets multiplied by their borrow factors|


### isOperator

Returns if '_spender' is an operator of '_owner'


```solidity
function isOperator(address _owner, address _spender) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The address of the owner|
|`_spender`|`address`|The address of the spender|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the spender is an operator of the owner, false otherwise|


### allowance

Returns the remaining amount of tokens that `spender` will be allowed to spend on
behalf of `owner` through {transferFrom}

*This value changes when {approve} or {transferFrom} are called*


```solidity
function allowance(address erc20, address _owner, address spender) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The address of the ERC20 to be checked|
|`_owner`|`address`|The wallet address whose `erc20` are allowed to be transferred by `spender`|
|`spender`|`address`|The wallet address who is allowed to spend `erc20` of `_owner`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|the remaining amount of tokens that `spender` will be allowed to spend on behalf of `owner` through {transferFrom}|


### computeInterestRate

Compute the interest rate of `underlying`


```solidity
function computeInterestRate(uint16 erc20Idx) external view returns (int96);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20Idx`|`uint16`|The underlying asset|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int96`|The interest rate of `erc20Idx`|


### getImplementation

provides the specific version of walletLogic contract that is associated with `wallet`


```solidity
function getImplementation(address wallet) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|Address of wallet whose walletLogic contract should be returned|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the address of the walletLogic contract that is associated with the `wallet`|


### getWalletOwner

provides the owner of `wallet`. Owner of the wallet is the address who created the wallet


```solidity
function getWalletOwner(address wallet) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of wallet whose owner should be returned|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the owner address of the `wallet`. Owner is the one who created the `wallet`|


### isSolvent

Checks if the account's positions are overcollateralized

*checks the eventual state of `executeBatch` function execution:
* `wallet` must have collateral >= debt
* Supa must have sufficient balance of deposits and loans for each ERC20 token*

*when called by the end of `executeBatch`, isSolvent checks the potential target state
of Supa. Calling this function separately would check current state of Supa, that is always
solvable, and so the return value would always be `true`, unless the `wallet` is liquidatable*


```solidity
function isSolvent(address wallet) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of a wallet who performed the `executeBatch`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether the position is solvent.|


## Events
### ERC20Transfer
Emitted when ERC20 tokens are transferred between credit accounts


```solidity
event ERC20Transfer(address indexed erc20, uint16 erc20Idx, address indexed from, address indexed to, int256 value);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The address of the ERC20 token|
|`erc20Idx`|`uint16`|The index of the ERC20 in the protocol|
|`from`|`address`|The address of the sender|
|`to`|`address`|The address of the receiver|
|`value`|`int256`|The amount of tokens transferred|

### ERC20BalanceChanged
Emitted when erc20 tokens are deposited or withdrawn from a credit account


```solidity
event ERC20BalanceChanged(address indexed erc20, uint16 erc20Idx, address indexed to, int256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The address of the ERC20 token|
|`erc20Idx`|`uint16`|The index of the ERC20 in the protocol|
|`to`|`address`|The address of the wallet|
|`amount`|`int256`|The amount of tokens deposited or withdrawn|

### ERC721Transferred
Emitted when a ERC721 is transferred between credit accounts


```solidity
event ERC721Transferred(uint256 indexed nftId, address indexed from, address indexed to);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftId`|`uint256`|The nftId of the ERC721 token|
|`from`|`address`|The address of the sender|
|`to`|`address`|The address of the receiver|

### ERC721Deposited
Emitted when an ERC721 token is deposited to a credit account


```solidity
event ERC721Deposited(address indexed erc721, address indexed to, uint256 indexed tokenId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721`|`address`|The address of the ERC721 token|
|`to`|`address`|The address of the wallet|
|`tokenId`|`uint256`|The id of the token deposited|

### ERC721Withdrawn
Emitted when an ERC721 token is withdrawn from a credit account


```solidity
event ERC721Withdrawn(address indexed erc721, address indexed from, uint256 indexed tokenId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721`|`address`|The address of the ERC721 token|
|`from`|`address`|The address of the wallet|
|`tokenId`|`uint256`|The id of the token withdrawn|

### ERC20Approval
*Emitted when `owner` approves `spender` to spend `value` tokens on their behalf.*


```solidity
event ERC20Approval(
    address indexed erc20, uint16 erc20Idx, address indexed owner, address indexed spender, uint256 value
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The ERC20 token to approve|
|`erc20Idx`|`uint16`||
|`owner`|`address`|The address of the token owner|
|`spender`|`address`|The address of the spender|
|`value`|`uint256`|The amount of tokens to approve|

### ERC721Approval
*Emitted when `owner` enables `approved` to manage the `tokenId` token on collection `collection`.*


```solidity
event ERC721Approval(address indexed collection, address indexed owner, address indexed approved, uint256 tokenId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The address of the ERC721 collection|
|`owner`|`address`|The address of the token owner|
|`approved`|`address`|The address of the approved operator|
|`tokenId`|`uint256`|The ID of the approved token|

### ERC721Received
*Emitted when an ERC721 token is received*


```solidity
event ERC721Received(address indexed wallet, address indexed erc721, uint256 indexed tokenId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet receiving the token|
|`erc721`|`address`|The address of the ERC721 token|
|`tokenId`|`uint256`|The id of the token received|

### ApprovalForAll
*Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its erc20s.*


```solidity
event ApprovalForAll(address indexed collection, address indexed owner, address indexed operator, bool approved);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`collection`|`address`|The address of the collection|
|`owner`|`address`|The address of the owner|
|`operator`|`address`|The address of the operator|
|`approved`|`bool`|True if the operator is approved, false to revoke approval|

### OperatorAdded
*Emitted when an operator is added to a wallet*


```solidity
event OperatorAdded(address indexed wallet, address indexed operator);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|
|`operator`|`address`|The address of the operator|

### OperatorRemoved
*Emitted when an operator is removed from a wallet*


```solidity
event OperatorRemoved(address indexed wallet, address indexed operator);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|
|`operator`|`address`|The address of the operator|

### WalletLiquidated
Emitted when a wallet is liquidated


```solidity
event WalletLiquidated(address indexed wallet, address indexed liquidator, int256 collateral, int256 debt);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the liquidated wallet|
|`liquidator`|`address`|The address of the liquidator|
|`collateral`|`int256`||
|`debt`|`int256`||

## Structs
### Approval

```solidity
struct Approval {
    address ercContract;
    uint256 amountOrTokenId;
}
```

