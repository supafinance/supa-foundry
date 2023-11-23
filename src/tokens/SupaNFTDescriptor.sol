// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable max-line-length,quotes
pragma solidity ^0.8.19;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { ISupaNFTDescriptor } from "./interfaces/ISupaNFTDescriptor.sol";

//import { Errors } from "./libraries/Errors.sol";
//import { NFTSVG } from "./libraries/NFTSVG.sol";
//import { SVGElements } from "./libraries/SVGElements.sol";

/// @title SupaNFTDescriptor
/// @notice See the documentation in {ISupaNFTDescriptor}.
contract SupaNFTDescriptor is ISupaNFTDescriptor {
    using Strings for address;
    using Strings for string;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Needed to avoid Stack Too Deep.
    struct TokenURIVars {
        address asset;
        string assetSymbol;
        string json;
        string sablierAddress;
        string status;
        string svg;
    }

    // todo: get power credit balance
    // todo: get ETH balance
    // todo: get ens name?
    // todo: get number of supa wallets
    // todo: get number of tasks created
    // todo: get number of activeTasks


    /// @inheritdoc ISupaNFTDescriptor
    function tokenURI(IERC721Metadata sablier, uint256 streamId) external view override returns (string memory uri) {
        return '';
//        TokenURIVars memory vars;
//
//        // Load the contracts.
//        vars.sablier = ISablierV2Lockup(address(sablier));
//        vars.sablierAddress = address(sablier).toHexString();
//        vars.asset = address(vars.sablier.getAsset(streamId));
//        vars.assetSymbol = safeAssetSymbol(vars.asset);
//        vars.depositedAmount = vars.sablier.getDepositedAmount(streamId);
//
//        // Load the stream's data.
//        vars.status = stringifyStatus(vars.sablier.statusOf(streamId));
//        vars.streamedPercentage = calculateStreamedPercentage({
//            streamedAmount: vars.sablier.streamedAmountOf(streamId),
//            depositedAmount: vars.depositedAmount
//        });
//        vars.streamingModel = mapSymbol(sablier);
//
//        // Generate the SVG.
//        vars.svg = NFTSVG.generateSVG(
//            NFTSVG.SVGParams({
//                accentColor: generateAccentColor(address(sablier), streamId),
//                amount: abbreviateAmount({ amount: vars.depositedAmount, decimals: safeAssetDecimals(vars.asset) }),
//                assetAddress: vars.asset.toHexString(),
//                assetSymbol: vars.assetSymbol,
//                duration: calculateDurationInDays({
//                startTime: vars.sablier.getStartTime(streamId),
//                endTime: vars.sablier.getEndTime(streamId)
//            }),
//                sablierAddress: vars.sablierAddress,
//                progress: stringifyPercentage(vars.streamedPercentage),
//                progressNumerical: vars.streamedPercentage,
//                status: vars.status,
//                streamingModel: vars.streamingModel
//            })
//        );
//
//        // Generate the JSON metadata.
//        vars.json = string.concat(
//            '{"attributes":',
//            generateAttributes({
//                assetSymbol: vars.assetSymbol,
//                sender: vars.sablier.getSender(streamId).toHexString(),
//                status: vars.status
//            }),
//            ',"description":"',
//            generateDescription({
//                streamingModel: vars.streamingModel,
//                assetSymbol: vars.assetSymbol,
//                streamId: streamId.toString(),
//                sablierAddress: vars.sablierAddress,
//                assetAddress: vars.asset.toHexString()
//            }),
//            '","external_url":"https://sablier.com","name":"',
//            generateName({ streamingModel: vars.streamingModel, streamId: streamId.toString() }),
//            '","image":"data:image/svg+xml;base64,',
//            Base64.encode(bytes(vars.svg)),
//            '"}'
//        );
//
//        // Encode the JSON metadata in Base64.
//        uri = string.concat("data:application/json;base64,", Base64.encode(bytes(vars.json)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

//    /// @notice Creates an abbreviated representation of the provided amount, rounded down and prefixed with ">= ".
//    /// @dev The abbreviation uses these suffixes:
//    /// - "K" for thousands
//    /// - "M" for millions
//    /// - "B" for billions
//    /// - "T" for trillions
//    /// For example, if the input is 1,234,567, the output is ">= 1.23M".
//    /// @param amount The amount to abbreviate, denoted in units of `decimals`.
//    /// @param decimals The number of decimals to assume when abbreviating the amount.
//    /// @return abbreviation The abbreviated representation of the provided amount, as a string.
//    function abbreviateAmount(uint256 amount, uint256 decimals) internal pure returns (string memory) {
//        if (amount == 0) {
//            return "0";
//        }
//
//        uint256 truncatedAmount;
//        unchecked {
//            truncatedAmount = decimals == 0 ? amount : amount / 10 ** decimals;
//        }
//
//        // Return dummy values when the truncated amount is either very small or very big.
//        if (truncatedAmount < 1) {
//            return string.concat(SVGElements.SIGN_LT, " 1");
//        } else if (truncatedAmount >= 1e15) {
//            return string.concat(SVGElements.SIGN_GT, " 999.99T");
//        }
//
//        string[5] memory suffixes = ["", "K", "M", "B", "T"];
//        uint256 fractionalAmount;
//        uint256 suffixIndex = 0;
//
//        // Truncate repeatedly until the amount is less than 1000.
//        unchecked {
//            while (truncatedAmount >= 1000) {
//                fractionalAmount = (truncatedAmount / 10) % 100; // keep the first two digits after the decimal point
//                truncatedAmount /= 1000;
//                suffixIndex += 1;
//            }
//        }
//
//        // Concatenate the calculated parts to form the final string.
//        string memory prefix = string.concat(SVGElements.SIGN_GE, " ");
//        string memory wholePart = truncatedAmount.toString();
//        string memory fractionalPart = stringifyFractionalAmount(fractionalAmount);
//        return string.concat(prefix, wholePart, fractionalPart, suffixes[suffixIndex]);
//    }

    /// @notice Generates a pseudo-random HSL color by hashing together the `chainid`, the `sablier` address,
    /// and the `streamId`. This will be used as the accent color for the SVG.
    function generateAccentColor(address owner, uint256 streamId) internal view returns (string memory) {
        // The chain id is part of the hash so that the generated color is different across chains.
        uint256 chainId = block.chainid;

        // Hash the parameters to generate a pseudo-random bit field, which will be used as entropy.
        // | Hue     | Saturation | Lightness | -> Roles
        // | [31:16] | [15:8]     | [7:0]     | -> Bit positions
        uint32 bitField = uint32(uint256(keccak256(abi.encodePacked(chainId, owner, streamId))));

        unchecked {
        // The hue is a degree on a color wheel, so its range is [0, 360).
        // Shifting 16 bits to the right means using the bits at positions [31:16].
            uint256 hue = (bitField >> 16) % 360;

        // The saturation is a percentage where 0% is grayscale and 100%, but here the range is bounded to [20,100]
        // to make the colors more lively.
        // Shifting 8 bits to the right and applying an 8-bit mask means using the bits at positions [15:8].
            uint256 saturation = ((bitField >> 8) & 0xFF) % 80 + 20;

        // The lightness is typically a percentage between 0% (black) and 100% (white), but here the range
        // is bounded to [30,100] to avoid dark colors.
        // Applying an 8-bit mask means using the bits at positions [7:0].
            uint256 lightness = (bitField & 0xFF) % 70 + 30;

        // Finally, concatenate the HSL values to form an SVG color string.
            return string.concat("hsl(", hue.toString(), ",", saturation.toString(), "%,", lightness.toString(), "%)");
        }
    }
}