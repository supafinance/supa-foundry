// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TaskCreatorProxy is Proxy, Ownable {

    address public implementation;

    constructor(address implementation_) {
        implementation = implementation_;
    }

    function upgrade(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function _implementation() internal view override returns (address) {
        return implementation;
    }
}