// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Execution,ReturnDataLink} from "src/lib/Call.sol";

    struct DynamicExecution {
        Execution execution;
        ReturnDataLink[] dynamicData;
        uint8 operation; // 0 = staticcall, 1 = delegatecall
    }

interface IWalletLogic {
    event TokensApproved(address sender, uint256 amount, bytes data);
    event TokensReceived(address spender, address sender, uint256 amount, bytes data);

    /// @notice makes a batch of different calls from the name of wallet owner. Eventual state of
    /// creditAccount and Supa must be solvent, i.e. debt on creditAccount cannot exceed collateral on
    /// creditAccount and wallet and Supa reserve/debt must be sufficient
    /// @dev - this goes to supa.executeBatch that would immediately call WalletProxy.executeBatch
    /// from above of this file
    /// @param calls {address target, uint256 value, bytes callData}[], where
    ///   * to - is the address of the contract whose function should be called
    ///   * callData - encoded function name and it's arguments
    ///   * value - the amount of ETH to sent with the call
    function executeBatch(Execution[] memory calls) external payable;

    function executeBatch(DynamicExecution[] memory dynamicCalls) external payable;
}
