// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Execution, LinkedExecution} from "src/lib/Call.sol";
import {IWalletLogic, DynamicExecution} from "src/interfaces/IWalletLogic.sol";

/// @title Gelato Operator
/// @notice This contract acts as the operator for Gelato automated tasks
/// @dev This contract must be set as an operator on the target Wallet
contract GelatoOperator {
    address public immutable dedicatedSender;

    /// @notice Only the dedicated sender can call this function
    error OnlyDedicatedSender();

    constructor(address _dedicatedSender) {
        dedicatedSender = _dedicatedSender;
    }

    modifier onlyDedicatedSender() {
        if (msg.sender != dedicatedSender) revert OnlyDedicatedSender();
        _;
    }

    /// @notice Executes a batch of calls on a target contract
    /// @dev This contract must be set as an operator on the target Wallet
    /// @param _target The target Supa wallet
    /// @param _calls The calls to execute
    function execute(IWalletLogic _target, Execution[] calldata _calls) external onlyDedicatedSender {
        _target.executeBatch(_calls);
    }

    /// @notice Executes a batch of dynamic calls on a target contract
    /// @dev This contract must be set as an operator on the target Wallet
    /// @param _target The target Supa wallet
    /// @param _calls The calls to execute
    function execute(IWalletLogic _target, DynamicExecution[] calldata _calls) external onlyDedicatedSender {
        _target.executeBatch(_calls);
    }
}
