// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {FixedPoint96} from "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import {OracleLibrary} from "src/oracles/libraries/OracleLibrary.sol";
import {FullMath, TickMath} from "src/periphery/UniV3LPHelper.sol";

import {IERC20ValueOracle} from "src/interfaces/IERC20ValueOracle.sol";

import {ImmutableGovernance} from "src/lib/ImmutableGovernance.sol";

contract ERC20TwapOracle is ImmutableGovernance, IERC20ValueOracle {
    address public immutable poolAddress;
    bool public immutable isInverse;
    int256 public collateralFactor = 1 ether;
    int256 public borrowFactor = 1 ether;
    uint32 public twapInterval = 300; // interval in seconds (300 = 5 minutes)

    /// @notice Borrow factor must be greater than zero
    error InvalidBorrowFactor();

    constructor(address _poolAddress, bool _isInverse, address _owner) ImmutableGovernance(_owner) {
        poolAddress = _poolAddress;
        isInverse = _isInverse;
    }

    function calcValue(int256 balance) external view override returns (int256 value, int256 riskAdjustedValue) {
        if (balance == 0) return (0, 0);
        uint160 sqrtPriceX96 = getSqrtTwapX96(poolAddress, twapInterval);
        uint256 priceX96 = getPriceX96FromSqrtPriceX96(sqrtPriceX96);
        value = int256(priceX96 >> 96);
        if (isInverse) {
            value = 1 ether / value;
        }

        value = (value * balance) / 1 ether;

        if (balance > 0) {
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
        uint160 sqrtPriceX96 = getSqrtTwapX96(poolAddress, twapInterval);
        uint256 priceX96 = getPriceX96FromSqrtPriceX96(sqrtPriceX96);
        value = int256(priceX96 >> 96);
        if (isInverse) {
            value = 1 ether / value;
        } else {
            value /= 1e12;
        }
        collateralAdjustedValue = (value * collateralFactor) / 1 ether;
        borrowAdjustedValue = (value * 1 ether) / borrowFactor;
        return (value, collateralAdjustedValue, borrowAdjustedValue);
    }

    function getRiskFactors() external view returns (int256, int256) {
        return (collateralFactor, borrowFactor);
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

    function setTwapInterval(uint32 _twapInterval) external onlyGovernance {
        twapInterval = _twapInterval;
    }

    function getSqrtTwapX96(address _uniswapV3Pool, uint32 _twapInterval) public view returns (uint160 sqrtPriceX96) {
        uint32 oldestObservationSecondsAgo = OracleLibrary.getOldestObservationSecondsAgo(_uniswapV3Pool);
        if (_twapInterval == 0 || oldestObservationSecondsAgo == 0) {
            // return the current price if twapInterval == 0
            (sqrtPriceX96,,,,,,) = IUniswapV3Pool(_uniswapV3Pool).slot0();
        } else {
            if (_twapInterval > oldestObservationSecondsAgo) {
                _twapInterval = oldestObservationSecondsAgo;
            }
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = _twapInterval; // from (before)
            secondsAgos[1] = 0; // to (now)

            (int56[] memory tickCumulatives,) = IUniswapV3Pool(_uniswapV3Pool).observe(secondsAgos);

            // tick to price
            sqrtPriceX96 = TickMath.getSqrtRatioAtTick(
                int24((tickCumulatives[1] - tickCumulatives[0]) / int56(uint56(_twapInterval)))
            );
        }
    }

    function getPriceX96FromSqrtPriceX96(uint160 sqrtPriceX96) public pure returns (uint256 priceX96) {
        return FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, FixedPoint96.Q96);
    }

    function _setRiskFactors(int256 _collateralFactor, int256 _borrowFactor) internal {
        collateralFactor = _collateralFactor;
        borrowFactor = _borrowFactor;
        emit RiskFactorsSet(_collateralFactor, _borrowFactor);
    }
}
