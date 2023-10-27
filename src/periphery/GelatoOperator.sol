// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Call, LinkedCall} from "src/lib/Call.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";

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
    function execute(WalletProxy _target, Call[] calldata _calls) external onlyDedicatedSender {
        _target.executeBatch(_calls);
    }

    /// @notice Executes a batch of calls on a target contract
    /// @dev This contract must be set as an operator on the target Wallet
    /// @param _target The target Supa wallet
    /// @param _calls The calls to execute
    function executeLink(WalletLogic _target, LinkedCall[] calldata _calls) external onlyDedicatedSender {
        _target.executeBatchLink(_calls);
    }
}
