// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISupa} from "src/interfaces/ISupa.sol";

contract LiquidationBotHelper {
    ISupa public immutable supa;

    constructor(address _supa) {
        supa = ISupa(_supa);
    }

    struct ValuesStruct {
        int256 totalValue;
        int256 collateral;
        int256 debt;
    }

    function getRiskAdjustedPositionValuesBatch(address[] calldata supaWallets)
        external
        view
        returns (ValuesStruct[] memory values)
    {
        for (uint256 i = 0; i < supaWallets.length;) {
            (int256 totalValue, int256 collateral, int256 debt) = supa.getRiskAdjustedPositionValues(supaWallets[i]);
            values[i] = ValuesStruct(totalValue, collateral, debt);

            // iterate in an unchecked block to save gas
            unchecked {
                i++;
            }
        }
    }
}
