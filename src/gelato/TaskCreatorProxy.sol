// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Task Creator for Supa Automations
contract TaskCreatorProxy is Proxy, Ownable {

    address public implementation;

    function upgrade(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function _implementation() internal view override returns (address) {
        return implementation;
    }
}
