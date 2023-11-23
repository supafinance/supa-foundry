// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";

import {BoostModeHelper} from "src/periphery/BoostModeHelper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract getMaxBorrowable is Script {
    function run() external {
        address boostModeHelperAddress = vm.envAddress("BOOST_MODE_HELPER");

        address usdcOracleAddress = vm.envAddress("USDC_ORACLE");
        address wethOracleAddress = vm.envAddress("ETH_ORACLE");
        address uniOracleAddress = vm.envAddress("UNI_ORACLE");

        IERC20 usdc = IERC20(vm.envAddress("USDC_GOERLI"));

        address supaWallet = 0xEeA091F86855E02eA0141c25fCA981fDb6F9E90d;

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        BoostModeHelper boostModeHelper = BoostModeHelper(boostModeHelperAddress);

        (int256 maxBorrowableUsd, int256 maxBorrowableToken, uint256 accountRisk, int256 collateral, int256 debt) =
            boostModeHelper.getMaxBorrowable(supaWallet, usdc, usdcOracleAddress, 0, 6);

        console.logInt(maxBorrowableUsd);
        console.logInt(maxBorrowableToken);
        console.log(accountRisk);
        vm.stopBroadcast();
    }
}

// forge script script/data/getMaxBorrowable.s.sol:getMaxBorrowable --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
