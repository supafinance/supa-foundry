# UniHelper
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/UniHelper.sol)

**Inherits:**
IERC721Receiver


## State Variables
### supa
The supa contract


```solidity
ISupa public immutable supa;
```


### manager
The UniswapV3 NFT manager


```solidity
address public immutable manager;
```


### factory
The UniswapV3 factory


```solidity
address public immutable factory;
```


### swapRouter
The UniswapV3 swap router


```solidity
address public immutable swapRouter;
```


## Functions
### constructor


```solidity
constructor(address _supa, address _manager, address _factory, address _swapRouter);
```

### borrowTokens

*Must be approved as an operator on the sender*


```solidity
function borrowTokens(address[] calldata erc20s, uint256[] calldata amounts) external;
```

### swap

*Must be approved as an operator on the sender*


```solidity
function swap(ISwapRouter.ExactInputSingleParams memory params) external payable;
```

### swapAndDeposit

*Must be approved as an operator on the sender*


```solidity
function swapAndDeposit(ISwapRouter.ExactInputSingleParams memory params) external payable;
```

### mint

*Must be approved as an operator on the sender*


```solidity
function mint(INonfungiblePositionManager.MintParams memory params) external payable returns (uint256 tokenId);
```

### mintAndDeposit

Mint and deposit LP token to credit account


```solidity
function mintAndDeposit(INonfungiblePositionManager.MintParams memory params)
    external
    payable
    returns (uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`params`|`INonfungiblePositionManager.MintParams`|MintParams struct|


### onERC721Received


```solidity
function onERC721Received(address, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`||
|`from`|`address`||
|`tokenId`|`uint256`|The tokenId|
|`data`|`bytes`|The additional data passed with the call|


### _removeLiquidity


```solidity
function _removeLiquidity(uint256 tokenId, uint128 amountToRemove) internal returns (Call[] memory calls);
```

### _borrow


```solidity
function _borrow(address erc20, uint256 amount) internal returns (Call memory);
```

## Errors
### PositionAlreadyBalanced
The position is already balanced


```solidity
error PositionAlreadyBalanced();
```

### TransferFailed
ERC20 transfer failed


```solidity
error TransferFailed();
```

### ApprovalFailed
ERC20 approval failed


```solidity
error ApprovalFailed();
```

### InvalidManager
NFT is not a UniswapV3 LP token


```solidity
error InvalidManager();
```

### InvalidData
Invalid data


```solidity
error InvalidData();
```

