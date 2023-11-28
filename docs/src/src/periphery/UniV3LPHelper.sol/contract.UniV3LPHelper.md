# UniV3LPHelper
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/periphery/UniV3LPHelper.sol)

**Inherits:**
IERC721Receiver


## State Variables
### supa
The supa contract


```solidity
ISupa public supa;
```


### manager
The UniswapV3 NFT manager


```solidity
address public manager;
```


### factory
The UniswapV3 factory


```solidity
address public factory;
```


### swapRouter
The UniswapV3 swap router


```solidity
address public swapRouter;
```


### MIN_64X64

```solidity
int128 private constant MIN_64X64 = -0x80000000000000000000000000000000;
```


### MAX_64X64

```solidity
int128 private constant MAX_64X64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
```


## Functions
### constructor


```solidity
constructor(address _supa, address _manager, address _factory, address _swapRouter);
```

### mintAndDeposit

Mint and deposit LP token to credit account


```solidity
function mintAndDeposit(
    address token0,
    address token1,
    uint24 fee,
    int24 tickLower,
    int24 tickUpper,
    uint256 amount0Desired,
    uint256 amount1Desired,
    uint256 amount0Min,
    uint256 amount1Min,
    address recipient,
    uint256 deadline
) external payable returns (uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token0`|`address`|The token0 address|
|`token1`|`address`|The token1 address|
|`fee`|`uint24`|The fee|
|`tickLower`|`int24`|The lower tick|
|`tickUpper`|`int24`|The upper tick|
|`amount0Desired`|`uint256`|The desired amount of token0|
|`amount1Desired`|`uint256`|The desired amount of token1|
|`amount0Min`|`uint256`|The minimum amount of token0|
|`amount1Min`|`uint256`|The minimum amount of token1|
|`recipient`|`address`|The recipient address|
|`deadline`|`uint256`|The deadline|


### reinvest

Collect fees and reinvest


```solidity
function reinvest(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|LP token ID|


### quickWithdraw

Remove liquidity and collect fees


```solidity
function quickWithdraw(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|LP token ID|


### quickWithdrawPercentage

Remove liquidity and collect fees


```solidity
function quickWithdrawPercentage(uint256 tokenId, uint8 percentage) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|LP token ID|
|`percentage`|`uint8`|The percentage of liquidity to withdraw|


### rebalance

Rebalance position with specified ticks


```solidity
function rebalance(uint256 tokenId, int24 tickLower, int24 tickUpper) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|LP token ID|
|`tickLower`|`int24`||
|`tickUpper`|`int24`||


### rebalanceSameTickSizing

Rebalance position using the same tick spacing at the current price


```solidity
function rebalanceSameTickSizing(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|LP token ID|


### getMintAmounts


```solidity
function getMintAmounts(
    address poolAddress,
    int24 tickLower,
    int24 tickUpper,
    uint256 amount0Desired,
    uint256 amount1Desired
) external view returns (int256 amount0, int256 amount1);
```

### swapAndDeposit

Swaps tokens and deposits the output token to the supa contract


```solidity
function swapAndDeposit(
    bytes memory _path,
    uint256 _amountIn,
    uint256 _amountOutMinimum,
    address tokenIn,
    address tokenOut
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_path`|`bytes`|The path to swap|
|`_amountIn`|`uint256`|The amount of the first token in the path to swap|
|`_amountOutMinimum`|`uint256`|The minimum amount of the last token in the path to receive|
|`tokenIn`|`address`||
|`tokenOut`|`address`||


### swapAndDeposit

Swaps tokens and deposits the output token to the supa contract


```solidity
function swapAndDeposit(uint256 _amountIn, uint256 _amountOutMinimum, address tokenIn, address tokenOut, uint24 fee)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amountIn`|`uint256`|The amount of the first token in the path to swap|
|`_amountOutMinimum`|`uint256`|The minimum amount of the last token in the path to receive|
|`tokenIn`|`address`||
|`tokenOut`|`address`||
|`fee`|`uint24`||


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


### _reinvest


```solidity
function _reinvest(uint256 tokenId) internal returns (uint256 amount0, uint256 amount1);
```

### _quickWithdraw


```solidity
function _quickWithdraw(uint256 tokenId, address from, uint8 percentage) internal returns (bool);
```

### _rebalance


```solidity
function _rebalance(uint256 tokenId, int24 tickLower, int24 tickUpper) internal;
```

### divRound


```solidity
function divRound(int128 x, int128 y) internal pure returns (int128 result);
```

### div

Calculate x / y rounding towards zero.  Revert on overflow or when y is
zero.


```solidity
function div(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### nearestUsableTick


```solidity
function nearestUsableTick(int24 tick_, int24 tickSpacing) internal pure returns (int24 result);
```

## Events
### MintAndDeposit
Emitted when an LP token is minted and deposited


```solidity
event MintAndDeposit(address indexed wallet, uint256 indexed tokenId, uint256 amount0, uint256 amount1);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The wallet address|
|`tokenId`|`uint256`|The LP token ID|
|`amount0`|`uint256`|The amount of token0 deposited|
|`amount1`|`uint256`|The amount of token1 deposited|

### Reinvest
Emitted when fees are collected and reinvested


```solidity
event Reinvest(address indexed wallet, uint256 indexed tokenId, uint256 amount0, uint256 amount1);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The wallet address|
|`tokenId`|`uint256`|The LP token ID|
|`amount0`|`uint256`|The amount of token0 collected|
|`amount1`|`uint256`|The amount of token1 collected|

### QuickWithdraw
Emitted when liquidity is removed and fees are collected


```solidity
event QuickWithdraw(address indexed wallet, uint256 indexed tokenId, uint256 amount0, uint256 amount1);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The wallet address|
|`tokenId`|`uint256`|The LP token ID|
|`amount0`|`uint256`|The amount of token0 collected|
|`amount1`|`uint256`|The amount of token1 collected|

### Rebalance
Emitted when position is rebalanced


```solidity
event Rebalance(
    address indexed wallet,
    uint256 indexed oldTokenId,
    uint256 indexed newTokenId,
    int24 tickLower,
    int24 tickUpper,
    uint256 amount0,
    uint256 amount1
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The wallet address|
|`oldTokenId`|`uint256`|The original LP token ID|
|`newTokenId`|`uint256`|The new LP token ID|
|`tickLower`|`int24`|The lower tick|
|`tickUpper`|`int24`|The upper tick|
|`amount0`|`uint256`|The new token0 amount|
|`amount1`|`uint256`|The new token1 amount|

### SwapAndDeposit
Emitted when swap and deposit is called


```solidity
event SwapAndDeposit(
    address indexed wallet, uint256 indexed amountIn, uint256 indexed amountOut, address tokenIn, address tokenOut
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The wallet address|
|`amountIn`|`uint256`|The amount of tokenIn|
|`amountOut`|`uint256`|The amount of tokenOut|
|`tokenIn`|`address`|The token swapped in|
|`tokenOut`|`address`|The token swapped out|

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

### InvalidPercentage
Thrown when percentage is greater than 100


```solidity
error InvalidPercentage();
```

