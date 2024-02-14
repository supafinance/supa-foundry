// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Execution, LinkedExecution} from "src/lib/Call.sol";
import {IWalletLogic, DynamicExecution} from "src/interfaces/IWalletLogic.sol";

/// @title Proxied Operator
/// @notice This contract acts as an operator for automated tasks
/// @dev This contract must be set as an operator on the target Wallet
/// @dev Owner should be set to a multisig or governance contract
contract ProxiedOperator is Ownable {
    /// @notice Only the dedicated sender can call this function
    error OnlyDedicatedSender();

    address public dedicatedSender;

    constructor(address _dedicatedSender, address owner) {
        dedicatedSender = _dedicatedSender;
        _transferOwnership(owner);
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

    function setDedicatedSender(address _dedicatedSender) external onlyOwner {
        dedicatedSender = _dedicatedSender;
    }
}
