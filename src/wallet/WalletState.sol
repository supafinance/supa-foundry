// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import {ISupa} from "src/interfaces/ISupa.sol";
import {FsUtils} from "src/lib/FsUtils.sol";

/// @title the state part of the WalletLogic. A parent to all contracts that form wallet
/// @dev the contract is abstract because it is not expected to be used separately from wallet
abstract contract WalletState {
    modifier onlyThis() {
        require(msg.sender == address(this), "WalletState: only this");
        _;
    }

    /// @notice The address cannot be the zero address
    error AddressZero();

    /// @dev Supa instance to be used by all other wallet contracts
    ISupa public supa;

    /// @param _supa - address of a deployed Supa contract
    constructor(address _supa) {
        // slither-disable-next-line missing-zero-check
        supa = ISupa(FsUtils.nonNull(_supa));
    }

    /// @notice Point the wallet to a new Supa contract
    /// @dev This function is only callable by the wallet itself
    /// @param _supa - address of a deployed Supa contract
    function updateSupa(address _supa) external onlyThis {
        // 1. Get the current wallet owner
        address currentOwner = supa.getWalletOwner(address(this));

        // 2. Update the supa implementation
        if (_supa == address(0) || _supa == address(supa)) {
            revert AddressZero();
        }
        supa = _supa;

        // 3. Call the new supa to update the wallet owner
        supa.migrateWallet(address(this), currentOwner);
    }
}
