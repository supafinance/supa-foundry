// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {GelatoBytes} from "./GelatoBytes.sol";
import {Module, ModuleData} from "./Types.sol";
import {AutomateTaskCreator} from "./AutomateTaskCreator.sol";
import {IOpsProxy} from "./interfaces/IOpsProxy.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {SupaState} from "src/supa/SupaState.sol";
import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Task Creator for Supa Automations
contract TaskCreator is Proxy, Ownable, AutomateTaskCreator {

    address public implementation;

    constructor(address _automate, address implementation_) AutomateTaskCreator(_automate, address(0)) {
        implementation = implementation_;
    }

    /// @notice Fund executions by depositing to 1Balance
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    function depositFunds1Balance(address token, uint256 amount) external payable {
        _depositFunds1Balance(amount, token, address(this));
    }

    function upgrade(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function _implementation() internal view override returns (address) {
        return implementation;
    }
}
