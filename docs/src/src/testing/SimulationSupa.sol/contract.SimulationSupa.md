# SimulationSupa
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/SimulationSupa.sol)

**Inherits:**
[SupaState](/src/supa/SupaState.sol/contract.SupaState.md), [ISupaCore](/src/interfaces/ISupa.sol/interface.ISupaCore.md), IERC721Receiver, Proxy


## State Variables
### K_NUMERAIRE_IDX

```solidity
uint16 constant K_NUMERAIRE_IDX = 0;
```


### POOL_ASSETS_CUTOFF

```solidity
uint256 constant POOL_ASSETS_CUTOFF = 100;
```


### supaConfigAddress

```solidity
address immutable supaConfigAddress;
```


## Functions
### onlyRegisteredNFT


```solidity
modifier onlyRegisteredNFT(address nftContract, uint256 tokenId);
```

### onlyNFTOwner


```solidity
modifier onlyNFTOwner(address nftContract, uint256 tokenId);
```

### constructor


```solidity
constructor(address supaConfig, address versionManagerAddress);
```

### depositERC20ForWallet

top up the creditAccount owned by wallet `to` with `amount` of `erc20`


```solidity
function depositERC20ForWallet(address erc20, address to, uint256 amount)
    external
    override
    walletExists(to)
    whenNotPaused;
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
function depositERC20(IERC20 erc20, uint256 amount) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`IERC20`|Address of the ERC20 token to be transferred|
|`amount`|`uint256`|The amount of `erc20` to be transferred|


### withdrawERC20

deposit `amount` of `erc20` from creditAccount tp wallet


```solidity
function withdrawERC20(IERC20 erc20, uint256 amount) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`IERC20`|Address of the ERC20 token to be transferred|
|`amount`|`uint256`|The amount of `erc20` to be transferred|


### depositFull

deposit all `erc20s` from wallet to creditAccount


```solidity
function depositFull(IERC20[] calldata erc20s) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20s`|`IERC20[]`|Array of addresses of ERC20 to be transferred|


### withdrawFull

withdraw all `erc20s` from creditAccount to wallet


```solidity
function withdrawFull(IERC20[] calldata erc20s) external onlyWallet whenNotPaused;
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
function depositERC721(address erc721Contract, uint256 tokenId)
    external
    override
    onlyWallet
    whenNotPaused
    onlyRegisteredNFT(erc721Contract, tokenId)
    onlyNFTOwner(erc721Contract, tokenId);
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
function depositERC721ForWallet(address erc721Contract, address to, uint256 tokenId)
    external
    override
    walletExists(to)
    whenNotPaused
    onlyRegisteredNFT(erc721Contract, tokenId)
    onlyNFTOwner(erc721Contract, tokenId);
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
function withdrawERC721(address erc721, uint256 tokenId) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721`|`address`|The address of the ERC721 contract that the token belongs to|
|`tokenId`|`uint256`|The id of the token to be transferred|


### transferERC20

transfer `amount` of `erc20` from creditAccount of caller wallet to creditAccount of `to` wallet


```solidity
function transferERC20(IERC20 erc20, address to, uint256 amount)
    external
    override
    onlyWallet
    whenNotPaused
    walletExists(to);
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
function transferERC721(address erc721, uint256 tokenId, address to)
    external
    override
    onlyWallet
    whenNotPaused
    walletExists(to);
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
function transferFromERC20(address erc20, address from, address to, uint256 amount)
    external
    override
    whenNotPaused
    walletExists(from)
    walletExists(to)
    returns (bool);
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
function transferFromERC721(address collection, address from, address to, uint256 tokenId)
    external
    override
    onlyWallet
    whenNotPaused
    walletExists(to);
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
function liquidate(address wallet) external override onlyWallet whenNotPaused walletExists(wallet);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of wallet whose creditAccount to be liquidate|


### addOperator

Add an operator for wallet

*Operator can execute batch of transactions on behalf of wallet owner*


```solidity
function addOperator(address operator) external override onlyWallet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address of the operator to add|


### removeOperator

Remove an operator for wallet

*Operator can execute batch of transactions on behalf of wallet owner*


```solidity
function removeOperator(address operator) external override onlyWallet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address of the operator to remove|


### migrateWallet

Unused function. Will be used in future versions


```solidity
function migrateWallet(address, address, address) external pure override;
```

### executeBatch

Execute a batch of calls

*execute a batch of commands on Supa from the name of wallet owner. Eventual state of
creditAccount and Supa must be solvent, i.e. debt on creditAccount cannot exceed collateral
and Supa reserve/debt must be sufficient*


```solidity
function executeBatch(Call[] memory calls) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|An array of transaction calls|


### onERC721Received

ERC721 transfer callback

*it's a callback, required to be implemented by IERC721Receiver interface for the
contract to be able to receive ERC721 NFTs.
We are using it to track what creditAccount owns what NFT.
`return this.onERC721Received.selector;` is mandatory part for the NFT transfer to work -
not a part of our business logic*


```solidity
function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
    external
    override
    whenNotPaused
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`||
|`from`|`address`|The address which previously owned the token|
|`tokenId`|`uint256`|The NFT identifier which is being transferred|
|`data`|`bytes`|Additional data with no specified format|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|`bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`|


### approveAndCall

Approve an array of tokens and then call `onApprovalReceived` on msg.sender


```solidity
function approveAndCall(Approval[] calldata approvals, address spender, bytes calldata data)
    external
    override
    onlyWallet
    whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`approvals`|`Approval[]`|An array of ERC20 tokens with amounts, or ERC721 contracts with tokenIds|
|`spender`|`address`|The address of the spender|
|`data`|`bytes`|Additional data with no specified format, sent in call to `spender`|


### getImplementation

provides the specific version of walletLogic contract that is associated with `wallet`


```solidity
function getImplementation(address wallet) external view override returns (address);
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
function getWalletOwner(address wallet) external view override returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of wallet whose owner should be returned|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the owner address of the `wallet`. Owner is the one who created the `wallet`|


### getERC721DataFromNFTId

Get the token data for a given NFT ID


```solidity
function getERC721DataFromNFTId(WalletLib.NFTId nftId) external view returns (address erc721, uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftId`|`WalletLib.NFTId`|The NFT ID to get the token data for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`erc721`|`address`|The address of the ERC721 contract|
|`tokenId`|`uint256`|The token ID|


### getRiskAdjustedPositionValues

returns the collateral, debt and total value of `walletAddress`.

*Notice that both collateral and debt has some coefficients on the actual amount of deposit
and loan assets! E.g.
for a deposit of 1 ETH the collateral would be equivalent to like 0.8 ETH, and
for a loan of 1 ETH the debt would be equivalent to like 1.2 ETH.
At the same time, totalValue is the unmodified difference between deposits and loans.*


```solidity
function getRiskAdjustedPositionValues(address walletAddress)
    public
    view
    override
    walletExists(walletAddress)
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


### getApproved

Returns the approved address for a token, or zero if no address set


```solidity
function getApproved(address collection, uint256 tokenId) public view override returns (address);
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


### isOperator

Returns if the 'spender' is an operator for the '_owner'


```solidity
function isOperator(address _owner, address spender) public view override returns (bool);
```

### allowance

Returns the remaining amount of tokens that `spender` will be allowed to spend on
behalf of `owner` through {transferFrom}

*This value changes when {approve} or {transferFrom} are called*


```solidity
function allowance(address erc20, address _owner, address spender) public view override returns (uint256);
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
function computeInterestRate(uint16 erc20Idx) public view override returns (int96);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20Idx`|`uint16`|The underlying asset|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int96`|The interest rate of `erc20Idx`|


### isSolvent

Checks if the account's positions are overcollateralized

*checks the eventual state of `executeBatch` function execution:
* `wallet` must have collateral >= debt
* Supa must have sufficient balance of deposits and loans for each ERC20 token*

*when called by the end of `executeBatch`, isSolvent checks the potential target state
of Supa. Calling this function separately would check current state of Supa, that is always
solvable, and so the return value would always be `true`, unless the `wallet` is liquidatable*


```solidity
function isSolvent(address) public pure returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether the position is solvent.|


### _approve


```solidity
function _approve(address _owner, address spender, address ercContract, uint256 amountOrTokenId, address erc721Spender)
    internal
    returns (uint256 prev);
```

### _spendAllowance

*changes the quantity of `erc20` by `amount` that are allowed to transfer from creditAccount
of wallet `_owner` by wallet `spender`*


```solidity
function _spendAllowance(address erc20, address _owner, address spender, uint256 amount) internal;
```

### _checkOnApprovalReceived

*Internal function to invoke {IERC1363Receiver-onApprovalReceived} on a target address
The call is not executed if the target address is not a contract*


```solidity
function _checkOnApprovalReceived(address spender, uint256 amount, address target, bytes memory data)
    internal
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`spender`|`address`|address The address which will spend the funds|
|`amount`|`uint256`|uint256 The amount of tokens to be spent|
|`target`|`address`||
|`data`|`bytes`|bytes Optional data to send along with the call|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|whether the call correctly returned the expected magic value|


### _transferERC20

*transfer ERC20 balances between creditAccounts.
Because all ERC20 tokens on creditAccounts are owned by Supa, no tokens are getting transferred -
all changes are inside Supa contract state*


```solidity
function _transferERC20(IERC20 erc20, address from, address to, int256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`IERC20`|The address of ERC20 token balance to transfer|
|`from`|`address`|The address of wallet whose creditAccount balance should be decreased by `amount`|
|`to`|`address`|The address of wallet whose creditAccount balance should be increased by `amount`|
|`amount`|`int256`|The amount of `erc20` by witch the balance of creditAccount of wallet `from` should be decreased and creditAccount of wallet `to` should be increased. Note that amount it can be negative|


### _transferNFT

*transfer ERC721 NFT ownership between creditAccounts.
Because all ERC721 NFTs on creditAccounts are owned by Supa, no NFT is getting transferred - all
changes are inside Supa contract state*


```solidity
function _transferNFT(WalletLib.NFTId nftId, address from, address to) internal;
```

### _transferAllERC20

*transfer all `erc20Idx` from `from` to `to`*


```solidity
function _transferAllERC20(uint16 erc20Idx, address from, address to) internal;
```

### _creditAccountERC20ChangeBy


```solidity
function _creditAccountERC20ChangeBy(address walletAddress, uint16 erc20Idx, int256 amount) internal;
```

### _creditAccountERC20Clear


```solidity
function _creditAccountERC20Clear(address walletAddress, uint16 erc20Idx) internal returns (int256);
```

### _extractPosition


```solidity
function _extractPosition(ERC20Share sharesWrapped, ERC20Info storage erc20Info) internal returns (int256 position);
```

### _insertPosition


```solidity
function _insertPosition(int256 amount, WalletLib.Wallet storage wallet, uint16 erc20Idx)
    internal
    returns (ERC20Share);
```

### _updateInterest


```solidity
function _updateInterest(uint16 erc20Idx) internal;
```

### _tokenStorageCheck


```solidity
function _tokenStorageCheck(address walletAddress) internal view;
```

### _getNFTId


```solidity
function _getNFTId(address erc721, uint256 tokenId) internal view returns (WalletLib.NFTId);
```

### _isApprovedOrOwner


```solidity
function _isApprovedOrOwner(address spender, WalletLib.NFTId nftId) internal view returns (bool);
```

### _implementation


```solidity
function _implementation() internal view override returns (address);
```

### getCreditAccountERC20


```solidity
function getCreditAccountERC20(address walletAddr, IERC20 erc20) external view returns (int256);
```

## Errors
### NotApprovedOrOwner
Sender is not approved to spend wallet erc20


```solidity
error NotApprovedOrOwner();
```

### NotOwner
Sender is not the owner of the wallet;


```solidity
error NotOwner(address sender, address owner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The address of the sender|
|`owner`|`address`|The address of the owner|

### InsufficientAllowance
Transfer amount exceeds allowance


```solidity
error InsufficientAllowance();
```

### SelfApproval
Cannot approve self as spender


```solidity
error SelfApproval();
```

### ReceiverNotContract
The receiving address is not a contract


```solidity
error ReceiverNotContract();
```

### ReceiverNoImplementation
The receiver does not implement the required interface


```solidity
error ReceiverNoImplementation();
```

### WrongDataReturned
The receiver did not return the correct value - transaction failed


```solidity
error WrongDataReturned();
```

### NotNFT
Asset is not an NFT


```solidity
error NotNFT();
```

### NotNFTOwner
NFT must be owned the the user or user's wallet


```solidity
error NotNFTOwner();
```

### Insolvent
Operation leaves wallet insolvent


```solidity
error Insolvent();
```

### CannotWithdrawDebt
Cannot withdraw debt


```solidity
error CannotWithdrawDebt();
```

### NotLiquidatable
Wallet is not liquidatable


```solidity
error NotLiquidatable();
```

### InsufficientReserves
There are insufficient reserves in the protocol for the debt


```solidity
error InsufficientReserves();
```

### TokenStorageExceeded
This operation would add too many tokens to the credit account


```solidity
error TokenStorageExceeded();
```

