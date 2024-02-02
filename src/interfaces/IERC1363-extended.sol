//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Execution} from "../lib/Call.sol";

interface IERC1363SpenderExtended {
    function onApprovalReceived(
        address owner,
        uint256 value,
        Execution calldata call
    ) external returns (bytes4);
}

interface IERC1363ReceiverExtended {
    function onTransferReceived(
        address operator,
        address token,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
}
