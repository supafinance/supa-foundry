// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISupa} from "src/interfaces/ISupa.sol";
import {IERC20ValueOracle} from "src/interfaces/IERC20ValueOracle.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BoostModeHelper {
    ISupa public immutable supa;

    constructor(address _supa) {
        supa = ISupa(_supa);
    }

    function getMaxBorrowable(
        address supaWallet,
        IERC20 erc20,
        address valueOracle,
        int256 borrowedAmountUsd,
        uint8 decimals
    )
        external
        view
        returns (
            int256 maxBorrowableUsd,
            int256 maxBorrowableToken,
            uint256 accountRisk,
            int256 collateral,
            int256 debt
        )
    {
        (, collateral, debt) = supa.getRiskAdjustedPositionValues(supaWallet);

        int256 value = collateral - debt;

        int256 borrowFactor = IERC20ValueOracle(valueOracle).borrowFactor();
        (, int256 collateralAdjustedValue, int256 borrowAdjustedValue) = IERC20ValueOracle(valueOracle).getValues();

        int256 factor = borrowFactor * 1 ether / (1 ether - ((borrowFactor ** 2) / 1 ether)); // scale: 1 ether

        maxBorrowableUsd = value * factor; // scale: ether ** 2

        if (borrowedAmountUsd > 0) maxBorrowableUsd += borrowedAmountUsd * (factor - 1 ether);

        maxBorrowableUsd /= 1 ether;

        int256 erc20Balance = supa.getCreditAccountERC20(supaWallet, erc20);

        if (erc20Balance > 0) {
            if (maxBorrowableUsd * int256(10 ** decimals) / collateralAdjustedValue < erc20Balance) {
                // all collateral
                maxBorrowableToken = maxBorrowableUsd * collateralAdjustedValue * int256(10 ** decimals) / (10 ** 12);
            } else {
                // some collateral + some debt
                (, int256 collateralValue) = IERC20ValueOracle(valueOracle).calcValue(erc20Balance);
                maxBorrowableToken =
                    erc20Balance + (((maxBorrowableUsd - collateralValue) * int256(10 ** 12)) / borrowAdjustedValue);
            }
        } else {
            // all debt
            maxBorrowableToken = maxBorrowableUsd * int256(10 ** decimals) / borrowAdjustedValue;
        }

        if (collateral == 0 && debt == 0) {
            accountRisk = 0;
        } else if (collateral == 0 && debt > 0) {
            accountRisk = type(uint256).max;
        } else {
            accountRisk = uint256((debt * 1 ether) / collateral);
        }

        return (maxBorrowableUsd, maxBorrowableToken, accountRisk, collateral, debt);
    }
}
