// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface TaskCreatorErrors {
    /// @notice Thrown when `msg.sender` is not the task owner
    error NotTaskOwner();

    /// @notice Thrown when `msg.sender` is not a supa wallet
    error NotSupaWallet();

    /// @notice Thrown when `user` does not have enough power credits
    error InsufficientPower(address user);

    /// @notice Thrown when `user` does not have enough USDC
    error InsufficientUsdcBalance(address user);

    /// @notice Thrown when unable to transfer USDC
    error UsdcTransferFailed();

    /// @notice Thrown when `msg.sender` is not authorized
    error Unauthorized();

    /// @notice Thrown when 'CID' is not authorized
    error UnauthorizedCID(string CID);

    /// @notice Thrown when attempting to cancel a solvent task not owned by the caller
    error TaskNotInsolvent(bytes32 taskId);

    /// @notice Thrown when an input address is the zero address
    error AddressZero();

    /// @notice Thrown when the power rate tiers are not set
    error TiersNotSet();

    /// @notice Thrown when the gas price feed returns a zero or negative price
    error InvalidPrice();
}

interface ITaskCreator is TaskCreatorErrors {
    struct Tier {
        uint256 limit;
        uint256 rate;
    }

    struct UserPowerData {
        uint256 lastUpdate;
        uint256 taskExecsPerSecond;
    }

    // 0x40dbef91e4485cfc36ac28f56d9214efc580977112e6dc20241ebaaa56692865
    /// @notice Emitted when a task is created
    event TaskCreated(
        bytes32 indexed taskId, address indexed taskOwner, uint256 automationId, string cid
    );

    /// @notice Emitted when power is purchased
    event PowerPurchased(address indexed user, uint256 indexed powerCredits, uint256 usdcAmount);

    /// @notice Emitted when power is used to pay for gas
    event GasPaidWithCredits(address indexed user, uint256 indexed gasAmount, uint256 creditAmount);
    event GasPaidNative(address indexed user, uint256 indexed gasAmount);

    /// @notice Emitted when power is given to a user by an admin
    event AdminPowerIncrease(address indexed user, uint256 indexed creditAmount);

    /// @notice Emitted when the fee tiers are set
    event FeeTiersSet(Tier[] tiers);

    /// @notice Emitted when the fee collector is set
    event FeeCollectorSet(address feeCollector);

    /// @notice Emitted when the deposit amount is set
    event DepositAmountSet(uint256 depositAmount);

    /// @notice Emitted when the power per execution is set
    event PowerPerExecutionSet(uint256 powerPerExecution);

    event GasPriceFeedSet(address gasPriceFeed);
}
