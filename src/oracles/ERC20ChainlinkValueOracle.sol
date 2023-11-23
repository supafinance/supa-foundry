// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {FsUtils} from "../lib/FsUtils.sol";
import {IERC20ValueOracle} from "../interfaces/IERC20ValueOracle.sol";

import {ImmutableGovernance} from "../lib/ImmutableGovernance.sol";

/// @notice Borrow factor must be greater than zero
error InvalidBorrowFactor();
/// @notice Chainlink price oracle must return a valid price (>0)
error InvalidPrice();

contract ERC20ChainlinkValueOracle is ImmutableGovernance, IERC20ValueOracle {
    AggregatorV3Interface public priceOracle;
    int256 public immutable base;
    int256 public collateralFactor = 1 ether;
    int256 public borrowFactor = 1 ether;

    modifier checkDecimals(string memory label, uint8 decimals) {
        if (decimals < 3 || 18 < decimals) {
            // prettier-ignore
            revert(
                string.concat(
                    "Invalid ", label, ": must be within [3, 18] range while provided is ", Strings.toString(decimals)
                )
            );
        }
        _;
    }

    constructor(
        address chainlink,
        uint8 baseDecimals,
        uint8 tokenDecimals,
        int256 _collateralFactor,
        int256 _borrowFactor,
        address _owner
    )
        ImmutableGovernance(_owner)
        checkDecimals("baseDecimals", baseDecimals)
        checkDecimals("tokenDecimals", tokenDecimals)
    {
        priceOracle = AggregatorV3Interface(FsUtils.nonNull(chainlink));
        base = int256(10) ** (tokenDecimals + priceOracle.decimals() - baseDecimals);
        _setRiskFactors(_collateralFactor, _borrowFactor);
    }

    /// @notice Set risk factors: collateral factor and borrow factor
    /// @param _collateralFactor Collateral factor
    /// @param _borrowFactor Borrow factor
    function setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) external onlyGovernance {
        if (_borrowFactor == 0) {
            revert InvalidBorrowFactor();
        }
        _setRiskFactors(_collateralFactor, _borrowFactor);
    }

    function getRiskFactors() external view returns (int256, int256) {
        return (collateralFactor, borrowFactor);
    }

    function calcValue(int256 balance) external view override returns (int256 value, int256 riskAdjustedValue) {
        (, int256 price,,,) = priceOracle.latestRoundData();
        if (price <= 0) {
            revert InvalidPrice();
        }
        value = (balance * price) / base;
        if (balance >= 0) {
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
        (, int256 price,,,) = priceOracle.latestRoundData();
        if (price <= 0) {
            revert InvalidPrice();
        }
        value = (price) / base;
        collateralAdjustedValue = (value * collateralFactor) / 1 ether;
        borrowAdjustedValue = (value * 1 ether) / borrowFactor;
        return (value, collateralAdjustedValue, borrowAdjustedValue);
    }

    function _setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) internal {
        collateralFactor = _collateralFactor;
        borrowFactor = _borrowFactor;
        emit RiskFactorsSet(_collateralFactor, _borrowFactor);
    }
}
