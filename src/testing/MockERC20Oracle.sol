// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20ValueOracle} from "../interfaces/IERC20ValueOracle.sol";
import {ImmutableGovernance} from "../lib/ImmutableGovernance.sol";

contract MockERC20Oracle is IERC20ValueOracle, ImmutableGovernance {
    int256 public price;
    int256 public collateralFactor = 1 ether;
    int256 public borrowFactor = 1 ether;

    uint256 public tokenDecimals;

    constructor(address owner) ImmutableGovernance(owner) {}

    /// @notice Sets the oracle price
    function setPrice(int256 _price, uint256 _tokenDecimals, uint256) external onlyGovernance {
        price = _price;
        tokenDecimals = _tokenDecimals;
    }

    /**
     * @notice Sets the risk factors (collateral factor & borrow factor)
     * @dev Emits a RiskFactorsSet event
     * @param _collateralFactor The new collateral factor
     * @param _borrowFactor The new borrow factor
     */
    function setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) external onlyGovernance {
        collateralFactor = _collateralFactor;
        borrowFactor = _borrowFactor;
        emit RiskFactorsSet(_collateralFactor, _borrowFactor);
    }

    function calcValue(int256 amount) external view override returns (int256 value, int256 riskAdjustedValue) {
        value = (amount * price) / int256(10 ** tokenDecimals);
        if (amount >= 0) {
            riskAdjustedValue = (value * collateralFactor) / 1 ether;
        } else {
            riskAdjustedValue = (value * 1 ether) / borrowFactor;
        }
        return (value, riskAdjustedValue);
    }

    function getValues()
        external
        view
        override
        returns (int256 value, int256 collateralAdjustedValue, int256 borrowAdjustedValue)
    {
        value = price;
        collateralAdjustedValue = (value * collateralFactor) / 1 ether;
        borrowAdjustedValue = (value * 1 ether) / borrowFactor;
        return (value, collateralAdjustedValue, borrowAdjustedValue);
    }
}
