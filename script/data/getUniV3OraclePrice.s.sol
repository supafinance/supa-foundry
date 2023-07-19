// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract getUniV3OraclePrice is Script {
    function run() external {
        address uniV3OracleAddressOld = vm.envAddress("UNI_V3_ORACLE_OLD");
        address uniV3OracleAddress = vm.envAddress("UNI_V3_ORACLE");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 tokenId = 73303;
        UniV3Oracle uniV3OracleOld = UniV3Oracle(uniV3OracleAddressOld);
        UniV3Oracle uniV3OracleNew = UniV3Oracle(uniV3OracleAddress);
        (int256 valueOld, int256 riskAdjustedValueOld) = uniV3OracleOld.calcValue(tokenId);
        (int256 value, int256 riskAdjustedValue) = uniV3OracleNew.calcValue(tokenId);

        vm.stopBroadcast();
    }
}

// forge script script/data/getUniV3OraclePrice.s.sol:getUniV3OraclePrice --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
