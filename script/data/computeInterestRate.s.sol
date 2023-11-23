// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";

contract computeInterestRate is Script {
    function run() external {

        address payable supaAddress = payable(vm.envAddress("SUPA"));

        Supa supa = Supa(supaAddress);
        int96 interestRate0 = supa.computeInterestRate(0);
        console.log("interestRate0: ");
        console.logInt(interestRate0);
        int96 interestRate1 = supa.computeInterestRate(1);
        console.log("interestRate1: ");
        console.logInt(interestRate1);
        int96 interestRate2 = supa.computeInterestRate(2);
        console.log("interestRate2: ");
        console.logInt(interestRate2);
    }
}

// forge script script/data/computeInterestRate.s.sol:computeInterestRate --rpc-url $GOERLI_RPC_URL -vvvv
