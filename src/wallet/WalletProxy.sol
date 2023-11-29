// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";

import {WalletState} from "./WalletState.sol";
import {ITransferReceiver2, TRANSFER_AND_CALL2} from "src/interfaces/ITransferReceiver2.sol";
import {PERMIT2} from "src/external/interfaces/IPermit2.sol";
import {FsUtils} from "src/lib/FsUtils.sol";
import {CallLib, Call} from "src/lib/Call.sol";

/// @title Wallet Proxy
/// @notice Proxy contract for Supa Wallets
// Inspired by TransparentUpdatableProxy
contract WalletProxy is WalletState, Proxy {
    modifier ifSupa() {
        if (msg.sender == address(supa)) {
            _;
        } else {
            _fallback();
        }
    }

    constructor(
        address _supa
    ) WalletState(_supa) {
        // solhint-disable-next-line no-empty-blocks
    }

    /// @dev Allow ETH transfers
    receive() external payable override {}

    // Allow Supa to make arbitrary calls in lieu of this wallet
    function executeBatch(Call[] calldata calls) external payable ifSupa {
        // Function is payable to allow for ETH transfers to the logic
        // contract, but supa should never send eth (supa contract should
        // never contain eth / other than what's self-destructed into it)
        FsUtils.Assert(msg.value == 0);
        CallLib.executeBatch(calls);
    }

    // The implementation of the delegate is controlled by Supa
    function _implementation() internal view override returns (address) {
        return supa.getImplementation(address(this));
    }
}
