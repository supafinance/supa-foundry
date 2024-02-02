// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {Supa} from "src/supa/Supa.sol";
import {ISupa} from "src/interfaces/ISupa.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {INonfungiblePositionManager} from "src/external/interfaces/INonfungiblePositionManager.sol";
import {Execution} from "src/lib/Call.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";

/// @title Supa UniswapV3 Helper
contract UniHelper is IERC721Receiver {
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

    /// @notice The supa contract
    ISupa public immutable supa;
    /// @notice The UniswapV3 NFT manager
    address public immutable manager;
    /// @notice The UniswapV3 factory
    address public immutable factory;
    /// @notice The UniswapV3 swap router
    address public immutable swapRouter;

    constructor(address _supa, address _manager, address _factory, address _swapRouter) {
        supa = ISupa(_supa);
        manager = _manager;
        factory = _factory;
        swapRouter = _swapRouter;
    }

    /// @dev Must be approved as an operator on the sender
    function borrowTokens(address[] calldata erc20s, uint256[] calldata amounts) external {
        Execution[] memory calls = new Execution[](erc20s.length);
        for (uint256 i = 0; i < erc20s.length; i++) {
            calls[i] = (_borrow(erc20s[i], amounts[i]));
        }
        WalletLogic(msg.sender).executeBatch(calls);
    }

    /// @dev Must be approved as an operator on the sender
    function swap(ISwapRouter.ExactInputSingleParams memory params) external payable {
        Execution[] memory calls = new Execution[](2);
        // calls[0] is the token approval
        calls[0] = Execution({
            target: params.tokenIn,
            callData: abi.encodeWithSelector(IERC20.approve.selector, swapRouter, params.amountIn),
            value: 0
        });

        // calls[1] is the swap
        calls[1] = Execution({
            target: swapRouter,
            callData: abi.encodeWithSelector(ISwapRouter.exactInputSingle.selector, params),
            value: 0
        });

        WalletLogic(msg.sender).executeBatch(calls);
    }

    /// @dev Must be approved as an operator on the sender
    function swapAndDeposit(ISwapRouter.ExactInputSingleParams memory params) external payable {
        Execution[] memory calls = new Execution[](3);
        // calls[0] is the token approval
        calls[0] = Execution({
            target: params.tokenIn,
            callData: abi.encodeWithSelector(IERC20.approve.selector, swapRouter, params.amountIn),
            value: 0
        });

        // calls[1] is the swap
        calls[1] = Execution({
            target: swapRouter,
            callData: abi.encodeWithSelector(ISwapRouter.exactInputSingle.selector, params),
            value: 0
        });

        // calls[2] is the deposit
        calls[2] = Execution({
            target: address(supa),
            callData: abi.encodeWithSelector(Supa.depositERC20.selector, params.tokenOut, params.amountOutMinimum),
            value: 0
        });

        WalletLogic(msg.sender).executeBatch(calls);
    }

    /// @dev Must be approved as an operator on the sender
    function mint(INonfungiblePositionManager.MintParams memory params) external payable returns (uint256 tokenId) {
        Execution[] memory calls = new Execution[](3);
        // calls[0] is the token0 approval
        calls[0] = Execution({
            target: params.token0,
            callData: abi.encodeWithSelector(IERC20.approve.selector, manager, params.amount0Desired),
            value: 0
        });

        // calls[1] is the token1 approval
        calls[1] = Execution({
            target: params.token1,
            callData: abi.encodeWithSelector(IERC20.approve.selector, manager, params.amount1Desired),
            value: 0
        });

        // calls[2] is the mint
        calls[2] = Execution({
            target: manager,
            callData: abi.encodeWithSelector(INonfungiblePositionManager.mint.selector, params),
            value: 0
        });

        WalletLogic(msg.sender).executeBatch(calls);
    }

    /// @notice Mint and deposit LP token to credit account
    /// @param params MintParams struct
    function mintAndDeposit(INonfungiblePositionManager.MintParams memory params)
        external
        payable
        returns (uint256 tokenId)
    {
        Execution[] memory calls = new Execution[](4);
        // calls[0] is to forwardNFTs
        calls[0] = Execution({
            target: msg.sender,
            callData: abi.encodeWithSelector(WalletLogic.forwardNFTs.selector, true),
            value: 0
        });

        // calls[1] is the token0 approval
        calls[1] = Execution({
            target: params.token0,
            callData: abi.encodeWithSelector(IERC20.approve.selector, manager, params.amount0Desired),
            value: 0
        });

        // calls[2] is the token1 approval
        calls[2] = Execution({
            target: params.token1,
            callData: abi.encodeWithSelector(IERC20.approve.selector, manager, params.amount1Desired),
            value: 0
        });

        // calls[3] is the mint
        calls[3] = Execution({
            target: manager,
            callData: abi.encodeWithSelector(INonfungiblePositionManager.mint.selector, params),
            value: 0
        });

        WalletLogic(msg.sender).executeBatch(calls);
    }

    /// @param tokenId The tokenId
    /// @param data The additional data passed with the call
    function onERC721Received(
        address, // operator
        address from, // from
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        if (msg.sender != address(manager)) {
            revert InvalidManager();
        }
        // if (data[0] == 0x00) {
        //     // reinvest
        //     _reinvest(tokenId);
        //     // deposit LP token to credit account
        //     supa.depositERC721ForWallet(manager, from, tokenId);
        // } else if (data[0] == 0x01) {
        //     // quick withdraw
        //     bool success = _quickWithdraw(tokenId, from);
        //     if (!success) {
        //         revert("Quick withdraw failed");
        //     }
        //     // transfer lp token to msg.sender
        //     IERC721(address(manager)).transferFrom(address(this), from, tokenId);
        // } else if (data[0] == 0x02) {
        //     // rebalance
        // }

        return this.onERC721Received.selector;
    }

    function _removeLiquidity(uint256 tokenId, uint128 amountToRemove) internal returns (Execution[] memory calls) {
        calls = new Execution[](2);
        // calls[0] removes liquidity
        calls[0] = Execution({
            target: manager,
            value: 0,
            callData: abi.encodeWithSelector(
                INonfungiblePositionManager(manager).decreaseLiquidity.selector,
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: tokenId,
                    liquidity: amountToRemove,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                })
                )
        });

        // calls[1] collect tokens
        calls[1] = Execution({
            target: manager,
            value: 0,
            callData: abi.encodeWithSelector(
                INonfungiblePositionManager(manager).collect.selector,
                INonfungiblePositionManager.CollectParams({
                    tokenId: tokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
                )
        });
    }

    function _borrow(address erc20, uint256 amount) internal returns (Execution memory) {
        return Execution({
            target: address(supa),
            callData: abi.encodeWithSelector(supa.withdrawERC20.selector, erc20, amount),
            value: 0
        });
    }
}
