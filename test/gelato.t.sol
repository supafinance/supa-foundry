// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

import {WalletProxy} from "src/wallet/WalletProxy.sol";

contract GelatoTest is Test {
    GelatoOperator public gelatoOperator;
    WalletProxy public walletProxy;

    function setUp() public {
        address dedicatedSender = address(this);
        gelatoOperator = new GelatoOperator(dedicatedSender);
    }

    // function testAddOperator() public {
    //     address target = address(this);
    //     walletProxy.addOperator(target);
    // }

    function testDedicatedSender() public {
        address dedicatedSender = address(this);
        assertEq(gelatoOperator.dedicatedSender(), dedicatedSender);
    }

    // function testExecute() public {
    //     address target = address(this);
    //     Call[] memory calls = new Call[](0);
    //     gelatoOperator.execute(target, calls);
    // }
}
