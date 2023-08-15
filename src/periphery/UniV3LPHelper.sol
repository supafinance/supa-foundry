// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {INonfungiblePositionManager} from "src/external/interfaces/INonfungiblePositionManager.sol";
import {ISupa} from "src/interfaces/ISupa.sol";
import {Call} from "src/lib/Call.sol";
import {FixedPoint96} from "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import {SafeCast} from "src/lib/SafeCast.sol";
import {Path} from "src/lib/Path.sol";

/// @title Supa UniswapV3 LP Position Helper
contract UniV3LPHelper is IERC721Receiver {
    using Path for bytes;

    /// @notice The supa contract
    ISupa public supa;
    /// @notice The UniswapV3 NFT manager
    address public manager;
    /// @notice The UniswapV3 factory
    address public factory;
    /// @notice The UniswapV3 swap router
    address public swapRouter;

    /// @notice The position is already balanced
    error PositionAlreadyBalanced();
    /// @notice ERC20 transfer failed
    error TransferFailed();
    /// @notice ERC20 approval failed
    error ApprovalFailed();
    /// @notice NFT is not a UniswapV3 LP token
    error InvalidManager();
    /// @notice Invalid data
    error InvalidData();
    /// @notice Thrown when percentage is greater than 100
    error InvalidPercentage();

    /// @notice Emitted when an LP token is minted and deposited
    /// @param wallet The wallet address
    /// @param tokenId The LP token ID
    event MintAndDeposit(address indexed wallet, uint256 indexed tokenId);

    /// @notice Emitted when fees are collected and reinvested
    /// @param wallet The wallet address
    /// @param tokenId The LP token ID
    /// @param amount0 The amount of token0 collected
    /// @param amount1 The amount of token1 collected
    event Reinvest(address indexed wallet, uint256 indexed tokenId, uint256 amount0, uint256 amount1);

    /// @notice Emitted when liquidity is removed and fees are collected
    /// @param wallet The wallet address
    /// @param tokenId The LP token ID
    /// @param amount0 The amount of token0 collected
    /// @param amount1 The amount of token1 collected
    event QuickWithdraw(address indexed wallet, uint256 indexed tokenId, uint256 amount0, uint256 amount1);

    /// @notice Emitted when position is rebalanced
    /// @param wallet The wallet address
    /// @param oldTokenId The original LP token ID
    /// @param newTokenId The new LP token ID
    /// @param tickLower The lower tick
    /// @param tickUpper The upper tick
    /// @param amount0 The new token0 amount
    /// @param amount1 The new token1 amount
    event Rebalance(
        address indexed wallet,
        uint256 indexed oldTokenId,
        uint256 indexed newTokenId,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when swap and deposit is called
    /// @param wallet The wallet address
    /// @param amountIn The amount of tokenIn
    /// @param amountOut The amount of tokenOut
    /// @param tokenIn The token swapped in
    /// @param tokenOut The token swapped out
    event SwapAndDeposit(
        address indexed wallet, uint256 indexed amountIn, uint256 indexed amountOut, address tokenIn, address tokenOut
    );

    constructor(address _supa, address _manager, address _factory, address _swapRouter) {
        supa = ISupa(_supa);
        manager = _manager;
        factory = _factory;
        swapRouter = _swapRouter;

        IERC721(manager).setApprovalForAll(_supa, true);
    }

    /// @notice Allows this contract to deposit `token` to a credit account
    /// @param token The token to approve
    function approveTokenForSupa(address token) external {
        IERC20(token).approve(address(supa), type(uint256).max);
    }

    /// @notice Mint and deposit LP token to credit account
    /// @param params MintParams struct
    function mintAndDeposit(INonfungiblePositionManager.MintParams memory params)
        external
        payable
        returns (uint256 tokenId)
    {
        // Transfer tokens to this contract
        if (
            !IERC20(params.token0).transferFrom(msg.sender, address(this), params.amount0Desired)
                || !IERC20(params.token1).transferFrom(msg.sender, address(this), params.amount1Desired)
        ) {
            revert TransferFailed();
        }

        // Approve tokens to manager
        if (
            !IERC20(params.token0).approve(manager, params.amount0Desired)
                || !IERC20(params.token1).approve(manager, params.amount1Desired)
        ) {
            revert ApprovalFailed();
        }

        // Update recipient to this contract
        params.recipient = address(this);

        // Mint LP token
        (tokenId,,,) = INonfungiblePositionManager(manager).mint(params);

        // Deposit LP token to credit account
        supa.depositERC721ForWallet(manager, msg.sender, tokenId);

        // send back excess tokens
        uint256 token0Balance = IERC20(params.token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(params.token1).balanceOf(address(this));
        supa.depositERC20ForWallet(params.token0, msg.sender, token0Balance);
        supa.depositERC20ForWallet(params.token1, msg.sender, token1Balance);

        emit MintAndDeposit(msg.sender, tokenId);
    }

    /// @notice Mint and deposit LP token to credit account
    /// @param token0 The token0 address
    /// @param token1 The token1 address
    /// @param fee The fee
    /// @param tickLower The lower tick
    /// @param tickUpper The upper tick
    /// @param amount0Desired The desired amount of token0
    /// @param amount1Desired The desired amount of token1
    /// @param amount0Min The minimum amount of token0
    /// @param amount1Min The minimum amount of token1
    /// @param recipient The recipient address
    /// @param deadline The deadline
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
    ) external payable returns (uint256 tokenId) {
        // Transfer tokens to this contract
        if (
            !IERC20(token0).transferFrom(msg.sender, address(this), amount0Desired)
                || !IERC20(token1).transferFrom(msg.sender, address(this), amount1Desired)
        ) {
            revert TransferFailed();
        }

        // Approve tokens to manager
        if (!IERC20(token0).approve(manager, amount0Desired) || !IERC20(token1).approve(manager, amount1Desired)) {
            revert ApprovalFailed();
        }

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: address(this),
            deadline: deadline
        });

        // Mint LP token
        (tokenId,,,) = INonfungiblePositionManager(manager).mint(params);

        // Deposit LP token to credit account
        supa.depositERC721ForWallet(manager, msg.sender, tokenId);

        // send back excess tokens
        uint256 token0Balance = IERC20(params.token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(params.token1).balanceOf(address(this));
        supa.depositERC20ForWallet(params.token0, msg.sender, token0Balance);
        supa.depositERC20ForWallet(params.token1, msg.sender, token1Balance);

        emit MintAndDeposit(msg.sender, tokenId);
    }

    /// @notice Collect fees and reinvest
    /// @param tokenId LP token ID
    function reinvest(uint256 tokenId) external {
        // transfer LP token to this contract
        IERC721(address(manager)).transferFrom(msg.sender, address(this), tokenId);

        (uint256 amount0, uint256 amount1) = _reinvest(tokenId); // increase gas cost

        // deposit LP token to credit account
        supa.depositERC721ForWallet(manager, msg.sender, tokenId);

        emit Reinvest(msg.sender, tokenId, amount0, amount1);
    }

    /// @notice Remove liquidity and collect fees
    /// @param tokenId LP token ID
    function quickWithdraw(uint256 tokenId) external {
        // transfer LP token to this contract
        IERC721(address(manager)).transferFrom(msg.sender, address(this), tokenId);

        _quickWithdraw(tokenId, msg.sender, 100);

        // transfer lp token to msg.sender
        IERC721(address(manager)).transferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice Remove liquidity and collect fees
    /// @param tokenId LP token ID
    /// @param percentage The percentage of liquidity to withdraw
    function quickWithdrawPercentage(uint256 tokenId, uint8 percentage) external {
        if (percentage > 100) {
            revert InvalidPercentage();
        }
        // transfer LP token to this contract
        IERC721(address(manager)).transferFrom(msg.sender, address(this), tokenId);

        _quickWithdraw(tokenId, msg.sender, percentage);

        // transfer lp token to msg.sender
        IERC721(address(manager)).transferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice Rebalance position with specified ticks
    /// @param tokenId LP token ID
    function rebalance(uint256 tokenId, int24 tickLower, int24 tickUpper) external {
        // transfer LP token to this contract
        IERC721(address(manager)).transferFrom(msg.sender, address(this), tokenId);

        _rebalance(tokenId, tickLower, tickUpper);

        // deposit LP token to credit account
        supa.depositERC721ForWallet(manager, msg.sender, tokenId);
    }

    /// @notice Rebalance position using the same tick spacing at the current price
    /// @param tokenId LP token ID
    function rebalanceSameTickSizing(uint256 tokenId) external {
        // transfer LP token to this contract
        IERC721(address(manager)).transferFrom(msg.sender, address(this), tokenId);

        // get current position values
        (
            ,
            ,
            address token0,
            address token1,
            uint24 fee,
            int24 currentTickLower,
            int24 currentTickUpper,
            uint128 liquidity,
            ,
            ,
            ,
        ) = INonfungiblePositionManager(manager).positions(tokenId);

        // remove liquidity
        INonfungiblePositionManager(manager).decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        // collect tokens
        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(manager).collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        // get pool
        IUniswapV3Pool pool = IUniswapV3Pool(IUniswapV3Factory(factory).getPool(token0, token1, fee));

        // get current tick
        (uint160 sqrtPriceX96, int24 currentTick,,,,,) = pool.slot0();

        // get tick spacing
        int24 tickSpacing = pool.tickSpacing();

        // get original tick spread
        int24 originalTickSpread = int24(currentTickUpper - currentTickLower) / 2;

        // get new tick lower
        int24 tickLower = nearestUsableTick(currentTick - originalTickSpread, tickSpacing);

        // get new tick upper
        int24 tickUpper = nearestUsableTick(currentTick + originalTickSpread, tickSpacing);

        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        // get token amounts given tickLower tickUpper and liquidity
        (uint256 amount0Desired, uint256 amount1Desired) =
            LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);

        ISwapRouter.ExactInputSingleParams memory params;
        if (amount0 > amount0Desired) {
            // swap token0 for token1
            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token0,
                tokenOut: token1,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount0 - amount0Desired,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            if (!IERC20(token0).approve(swapRouter, params.amountIn)) {
                revert ApprovalFailed();
            }
        } else if (amount1 > amount1Desired) {
            // swap token1 for token0
            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token1,
                tokenOut: token0,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount1 - amount1Desired,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            if (!IERC20(token1).approve(swapRouter, params.amountIn)) {
                revert ApprovalFailed();
            }
        } else {
            revert PositionAlreadyBalanced();
        }

        // swap tokens
        if (!IERC20(params.tokenIn).approve(swapRouter, params.amountIn)) {
            revert ApprovalFailed();
        }
        ISwapRouter(swapRouter).exactInputSingle(params);

        uint256 token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));

        // approve tokens to manager
        if (!IERC20(token0).approve(manager, amount0Desired) || !IERC20(token1).approve(manager, amount1Desired)) {
            revert ApprovalFailed();
        }

        // reinvest
        (uint256 newTokenId,,,) = INonfungiblePositionManager(manager).mint(
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: fee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: token0Balance,
                amount1Desired: token1Balance,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );

        // deposit LP token to credit account
        supa.depositERC721ForWallet(manager, msg.sender, newTokenId);

        {
            // return excess tokens
            uint256 returnToken0Balance = IERC20(token0).balanceOf(address(this));
            uint256 returnToken1Balance = IERC20(token1).balanceOf(address(this));

            if (returnToken0Balance > 0) {
                supa.depositERC20ForWallet(token0, msg.sender, returnToken0Balance);
            }
            if (returnToken1Balance > 0) {
                supa.depositERC20ForWallet(token1, msg.sender, returnToken1Balance);
            }
        }

        emit Rebalance(msg.sender, tokenId, newTokenId, tickLower, tickUpper, token0Balance, token1Balance);
    }

    function getMintAmounts(
        address poolAddress,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view returns (int256 amount0, int256 amount1) {
        (uint160 sqrtPriceX96, int24 tick,,,,,) = IUniswapV3Pool(poolAddress).slot0();

        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        int128 liquidity = int128(
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, amount0Desired, amount1Desired
            )
        );

        if (tick < tickLower) {
            // current tick is below the passed range; liquidity can only become in range by crossing from left to
            // right, when we'll need _more_ token0 (it's becoming more valuable) so user must provide it
            amount0 = SqrtPriceMath.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (tick < tickUpper) {
            // current tick is inside the passed range
            amount0 = SqrtPriceMath.getAmount0Delta(sqrtPriceX96, sqrtRatioBX96, liquidity);
            amount1 = SqrtPriceMath.getAmount1Delta(sqrtRatioAX96, sqrtPriceX96, liquidity);
        } else {
            // current tick is above the passed range; liquidity can only become in range by crossing from right to
            // left, when we'll need _more_ token1 (it's becoming more valuable) so user must provide it
            amount1 = SqrtPriceMath.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }

    /// @notice Swaps tokens and deposits the output token to the supa contract
    /// @param _path The path to swap
    /// @param _amountIn The amount of the first token in the path to swap
    /// @param _amountOutMinimum The minimum amount of the last token in the path to receive
    function swapAndDeposit(
        bytes memory _path,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        address tokenIn,
        address tokenOut
    ) external {
        if (!IERC20(tokenIn).transferFrom(msg.sender, address(this), _amountIn)) revert TransferFailed();
        // approve the swap router to spend the fiirst token in the path
        if (!IERC20(tokenIn).approve(swapRouter, _amountIn)) revert ApprovalFailed();

        {
            ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
                path: _path,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountOutMinimum
            });

            // Make the swap
            uint256 amountOut = ISwapRouter(swapRouter).exactInput(params);

            // approve the supa contract to spend the last token in the path
            if (!IERC20(tokenOut).approve(address(supa), amountOut)) revert ApprovalFailed();

            // Deposit amountOut to the supa contract
            supa.depositERC20ForWallet(tokenOut, msg.sender, amountOut);

            emit SwapAndDeposit(msg.sender, _amountIn, amountOut, tokenIn, tokenOut);
        }
    }

    /// @notice Swaps tokens and deposits the output token to the supa contract
    /// @param _amountIn The amount of the first token in the path to swap
    /// @param _amountOutMinimum The minimum amount of the last token in the path to receive
    function swapAndDeposit(uint256 _amountIn, uint256 _amountOutMinimum, address tokenIn, address tokenOut, uint24 fee)
        external
    {
        if (!IERC20(tokenIn).transferFrom(msg.sender, address(this), _amountIn)) revert TransferFailed();
        // approve the swap router to spend the fiirst token in the path
        if (!IERC20(tokenIn).approve(swapRouter, _amountIn)) revert ApprovalFailed();

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: _amountOutMinimum,
            sqrtPriceLimitX96: 0
        });

        // Make the swap
        uint256 amountOut = ISwapRouter(swapRouter).exactInputSingle(params);

        // approve the supa contract to spend the last token in the path
        if (!IERC20(tokenOut).approve(address(supa), amountOut)) revert ApprovalFailed();

        // Deposit amountOut to the supa contract
        supa.depositERC20ForWallet(tokenOut, msg.sender, amountOut);

        emit SwapAndDeposit(msg.sender, _amountIn, amountOut, tokenIn, tokenOut);
    }

    /// @param tokenId The tokenId
    /// @param data The additional data passed with the call
    function onERC721Received(
        address, // operator
        address from, // from
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
//        if (msg.sender != address(manager)) {
//            revert InvalidManager();
//        }
//        if (data[0] == 0x00) {
//            // reinvest
//            _reinvest(tokenId);
//            // deposit LP token to credit account
//            supa.depositERC721ForWallet(manager, from, tokenId);
//        } else if (data[0] == 0x01) {
//            // quick withdraw
//            bool success = _quickWithdraw(tokenId, from, 100);
//            if (!success) {
//                revert("Quick withdraw failed");
//            }
//            // transfer lp token to msg.sender
//            IERC721(address(manager)).transferFrom(address(this), from, tokenId);
//        } else if (data[0] == 0x02) {
//            // rebalance
//        }

        return this.onERC721Received.selector;
    }

    function _reinvest(uint256 tokenId) internal returns (uint256 amount0, uint256 amount1) {
        // collect accrued fees
        (amount0, amount1) = INonfungiblePositionManager(manager).collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        // get token addresses
        (,, address token0, address token1,,,,,,,,) = INonfungiblePositionManager(manager).positions(tokenId);

        // approve tokens to manager
        if (!IERC20(token0).approve(manager, amount0) || !IERC20(token1).approve(manager, amount1)) {
            revert ApprovalFailed();
        }

        // reinvest
        INonfungiblePositionManager(manager).increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        return (amount0, amount1);
    }

    function _quickWithdraw(uint256 tokenId, address from, uint8 percentage) internal returns (bool) {
        // get current position values
        (,, address token0, address token1,,,, uint128 liquidity,,,,) =
            INonfungiblePositionManager(manager).positions(tokenId);

        uint128 liquidityToWithdraw = percentage == 100 ? liquidity : liquidity * percentage / 100;

        // remove liquidity
        INonfungiblePositionManager(manager).decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidityToWithdraw,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        // collect tokens
        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(manager).collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        // approve tokens to supa
        if (!IERC20(token0).approve(address(supa), amount0) || !IERC20(token1).approve(address(supa), amount1)) {
            revert ApprovalFailed();
        }

        // deposit tokens to credit account
        if (amount0 > 0) {
            supa.depositERC20ForWallet(token0, from, amount0);
        }
        if (amount1 > 0) {
            supa.depositERC20ForWallet(token1, from, amount1);
        }

        emit QuickWithdraw(from, tokenId, amount0, amount1);

        return true;
    }

    function _rebalance(uint256 tokenId, int24 tickLower, int24 tickUpper) internal {
        // get current position values
        (,, address token0, address token1, uint24 fee,,, uint128 liquidity,,,,) =
            INonfungiblePositionManager(manager).positions(tokenId);

        // remove liquidity
        INonfungiblePositionManager(manager).decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        // collect tokens
        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(manager).collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        // get pool
        IUniswapV3Pool pool = IUniswapV3Pool(IUniswapV3Factory(factory).getPool(token0, token1, fee));

        // get current tick
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();

        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        // get token amounts given tickLower tickUpper and liquidity
        (uint256 amount0Desired, uint256 amount1Desired) =
            LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);

        ISwapRouter.ExactInputSingleParams memory params;
        if (amount0 > amount0Desired) {
            // swap token0 for token1
            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token0,
                tokenOut: token1,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount0 - amount0Desired,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            if (!IERC20(token0).approve(swapRouter, params.amountIn)) {
                revert ApprovalFailed();
            }
        } else if (amount1 > amount1Desired) {
            // swap token1 for token0
            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token1,
                tokenOut: token0,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount1 - amount1Desired,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            if (!IERC20(token1).approve(swapRouter, params.amountIn)) {
                revert ApprovalFailed();
            }
        } else {
            revert PositionAlreadyBalanced();
        }

        // swap tokens
        if (!IERC20(params.tokenIn).approve(swapRouter, params.amountIn)) {
            revert ApprovalFailed();
        }
        ISwapRouter(swapRouter).exactInputSingle(params);

        uint256 token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));

        // approve tokens to manager
        if (!IERC20(token0).approve(manager, amount0Desired) || !IERC20(token1).approve(manager, amount1Desired)) {
            revert ApprovalFailed();
        }

        // reinvest
        (uint256 newTokenId,,,) = INonfungiblePositionManager(manager).mint(
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: fee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: token0Balance,
                amount1Desired: token1Balance,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );

        // return excess tokens
        token0Balance = IERC20(token0).balanceOf(address(this));
        token1Balance = IERC20(token1).balanceOf(address(this));

        if (token0Balance > 0) {
            supa.depositERC20ForWallet(token0, msg.sender, token0Balance);
        }
        if (token1Balance > 0) {
            supa.depositERC20ForWallet(token1, msg.sender, token1Balance);
        }

        emit Rebalance(msg.sender, tokenId, newTokenId, tickLower, tickUpper, token0Balance, token1Balance);
    }

    function divRound(int128 x, int128 y) internal pure returns (int128 result) {
        int128 quot = div(x, y);
        result = quot >> 64;

        // Check if remainder is greater than 0.5
        if (quot % 2 ** 64 >= 0x8000000000000000) {
            result += 1;
        }
    }

    /*
     * Minimum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MIN_64X64 = -0x80000000000000000000000000000000;

    /*
     * Maximum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MAX_64X64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            require(y != 0, "div by 0");
            int256 result = (int256(x) << 64) / y;
            require(result >= MIN_64X64 && result <= MAX_64X64, "out of bounds");
            return int128(result);
        }
    }

    function nearestUsableTick(int24 tick_, int24 tickSpacing) internal pure returns (int24 result) {
        result = int24(divRound(int128(tick_), int128(tickSpacing))) * int24(tickSpacing);

        if (result < TickMath.MIN_TICK) {
            result += tickSpacing;
        } else if (result > TickMath.MAX_TICK) {
            result -= tickSpacing;
        }
    }
}

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    error T();
    error R();

    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            if (absTick > uint256(int256(MAX_TICK))) revert T();

            uint256 ratio =
                absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

            if (tick > 0) ratio = type(uint256).max / ratio;

            // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
            // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
            // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
            sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
        }
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        unchecked {
            // second inequality must be < because the price can never reach the price at the max tick
            if (!(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO)) revert R();
            uint256 ratio = uint256(sqrtPriceX96) << 32;

            uint256 r = ratio;
            uint256 msb = 0;

            assembly {
                let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(5, gt(r, 0xFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(4, gt(r, 0xFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(3, gt(r, 0xFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(2, gt(r, 0xF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(1, gt(r, 0x3))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := gt(r, 0x1)
                msb := or(msb, f)
            }

            if (msb >= 128) r = ratio >> (msb - 127);
            else r = ratio << (127 - msb);

            int256 _log2 = (int256(msb) - 128) << 64;

            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(63, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(62, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(61, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(60, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(59, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(58, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(57, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(56, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(55, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(54, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(53, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(52, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(51, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                _log2 := or(_log2, shl(50, f))
            }

            int256 logSqrt10001 = _log2 * 255738958999603826347141; // 128.128 number

            int24 tickLow = int24((logSqrt10001 - 3402992956809132418596140100660247210) >> 128);
            int24 tickHi = int24((logSqrt10001 + 291339464771989622907027621153398088495) >> 128);

            tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
        }
    }
}

library LiquidityAmounts {
    /// @notice Downcasts uint256 to uint128
    /// @param x The uint258 to be downcasted
    /// @return y The passed value, downcasted to uint128
    function toUint128(uint256 x) private pure returns (uint128 y) {
        require((y = uint128(x)) == x);
    }

    /// @notice Computes the amount of token0 for a given amount of liquidity and a price range
    /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
    /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
    /// @param liquidity The liquidity being valued
    /// @return amount0 The amount of token0
    function getAmount0ForLiquidity(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
        internal
        pure
        returns (uint256 amount0)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) {
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        }

        return FullMath.mulDiv(
            uint256(liquidity) << FixedPoint96.RESOLUTION, sqrtRatioBX96 - sqrtRatioAX96, sqrtRatioBX96
        ) / sqrtRatioAX96;
    }

    /// @notice Computes the amount of token1 for a given amount of liquidity and a price range
    /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
    /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
    /// @param liquidity The liquidity being valued
    /// @return amount1 The amount of token1
    function getAmount1ForLiquidity(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity)
        internal
        pure
        returns (uint256 amount1)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) {
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        }

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    /// @notice Computes the token0 and token1 value for a given amount of liquidity, the current
    /// pool prices and the prices at the tick boundaries
    /// @param sqrtRatioX96 A sqrt price representing the current pool prices
    /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
    /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
    /// @param liquidity The liquidity being valued
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) {
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        }

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }

    /// @notice Computes the amount of liquidity received for a given amount of token0 and price range
    /// @dev Calculates amount0 * (sqrt(upper) * sqrt(lower)) / (sqrt(upper) - sqrt(lower))
    /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
    /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
    /// @param amount0 The amount0 being sent in
    /// @return liquidity The amount of returned liquidity
    function getLiquidityForAmount0(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount0)
        internal
        pure
        returns (uint128 liquidity)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    /// @notice Computes the amount of liquidity received for a given amount of token1 and price range
    /// @dev Calculates amount1 / (sqrt(upper) - sqrt(lower)).
    /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
    /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
    /// @param amount1 The amount1 being sent in
    /// @return liquidity The amount of returned liquidity
    function getLiquidityForAmount1(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount1)
        internal
        pure
        returns (uint128 liquidity)
    {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    /// @notice Computes the maximum amount of liquidity received for a given amount of token0, token1, the current
    /// pool prices and the prices at the tick boundaries
    /// @param sqrtRatioX96 A sqrt price representing the current pool prices
    /// @param sqrtRatioAX96 A sqrt price representing the first tick boundary
    /// @param sqrtRatioBX96 A sqrt price representing the second tick boundary
    /// @param amount0 The amount of token0 being sent in
    /// @param amount1 The amount of token1 being sent in
    /// @return liquidity The maximum amount of liquidity received
    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }
}

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0, "div by 0");
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1, "denominator > prod1");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (0 - denominator) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max, "result overflow");
                result++;
            }
        }
    }
}

/// @title Functions based on Q64.96 sqrt price and liquidity
/// @notice Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas
library SqrtPriceMath {
    using SafeCast for uint256;

    /// @notice Gets the amount0 delta between two prices
    /// @dev Calculates liquidity / sqrt(lower) - liquidity / sqrt(upper),
    /// i.e. liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))
    /// @param sqrtRatioAX96 A sqrt price
    /// @param sqrtRatioBX96 Another sqrt price
    /// @param liquidity The amount of usable liquidity
    /// @param roundUp Whether to round the amount up or down
    /// @return amount0 Amount of token0 required to cover a position of size liquidity between the two passed prices
    function getAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity, bool roundUp)
        internal
        pure
        returns (uint256 amount0)
    {
        unchecked {
            if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

            uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
            uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

            require(sqrtRatioAX96 > 0);

            return roundUp
                ? UnsafeMath.divRoundingUp(FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96), sqrtRatioAX96)
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
        }
    }

    /// @notice Gets the amount1 delta between two prices
    /// @dev Calculates liquidity * (sqrt(upper) - sqrt(lower))
    /// @param sqrtRatioAX96 A sqrt price
    /// @param sqrtRatioBX96 Another sqrt price
    /// @param liquidity The amount of usable liquidity
    /// @param roundUp Whether to round the amount up, or down
    /// @return amount1 Amount of token1 required to cover a position of size liquidity between the two passed prices
    function getAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity, bool roundUp)
        internal
        pure
        returns (uint256 amount1)
    {
        unchecked {
            if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

            return roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
        }
    }

    /// @notice Helper that gets signed token0 delta
    /// @param sqrtRatioAX96 A sqrt price
    /// @param sqrtRatioBX96 Another sqrt price
    /// @param liquidity The change in liquidity for which to compute the amount0 delta
    /// @return amount0 Amount of token0 corresponding to the passed liquidityDelta between the two prices
    function getAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity)
        internal
        pure
        returns (int256 amount0)
    {
        unchecked {
            return liquidity < 0
                ? -getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
        }
    }

    /// @notice Helper that gets signed token1 delta
    /// @param sqrtRatioAX96 A sqrt price
    /// @param sqrtRatioBX96 Another sqrt price
    /// @param liquidity The change in liquidity for which to compute the amount1 delta
    /// @return amount1 Amount of token1 corresponding to the passed liquidityDelta between the two prices
    function getAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity)
        internal
        pure
        returns (int256 amount1)
    {
        unchecked {
            return liquidity < 0
                ? -getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
        }
    }
}

/// @title Math functions that do not check inputs or outputs
/// @notice Contains methods that perform common math functions but do not do any overflow or underflow checks
library UnsafeMath {
    /// @notice Returns ceil(x / y)
    /// @dev division by 0 has unspecified behavior, and must be checked externally
    /// @param x The dividend
    /// @param y The divisor
    /// @return z The quotient, ceil(x / y)
    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}
