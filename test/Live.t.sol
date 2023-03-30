// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {Supa, ISupa, WalletLib, SupaState, ISupaCore, IERC20, ERC20Info} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";

import {Call} from "src/lib/Call.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";

import {IVersionManager, VersionManager, ImmutableVersion} from "src/supa/VersionManager.sol";

import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {ERC20ChainlinkValueOracle} from "src/oracles/ERC20ChainlinkValueOracle.sol";
import {MockNFTOracle} from "src/testing/MockNFTOracle.sol";

import {TestERC20} from "src/testing/TestERC20.sol";
import {TestNFT} from "src/testing/TestNFT.sol";

contract SupaTest is Test {
    uint256 goerliFork;
    string GOERLI_RPC_URL = vm.envString("GOERLI_RPC_URL");

    VersionManager public versionManager =
        VersionManager(0xC91093422443Eb74DA3ace17364C2f6E0d91827f);
    Supa public supa = Supa(payable(0xddC7F4EFD50EfB562c9088267881ebdEd83A7285));

    WalletProxy public userWallet =
        WalletProxy(payable(0xdBb313f0043962ac65E38b92fcbAc7f7Eb84A800));

    IERC20 public weth = IERC20(payable(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6)); // goerli WETH

    IERC20 futureswapUSDC = IERC20(0x18e526F710B8d504A735927f5Eb8BdF2F4386811); // goerli USDC
    IERC20 uni = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984); // goerli UNI

    function setUp() public {
        goerliFork = vm.createFork(GOERLI_RPC_URL);
        vm.selectFork(goerliFork);
    }

    function test_GetRiskAdjustedPositionValues() public view {
        (int256 totalValue, int256 collateral, int256 debt) = supa.getRiskAdjustedPositionValues(
            address(userWallet)
        );
        
        console.log("totalValue");
        console.logInt(totalValue);
        console.log("collateral");
        console.logInt(collateral);
        console.log("debt");
        console.logInt(debt);
    }

    // function testERC20Addeds() public view {
    //     ERC20Info memory erc20s = SupaState(supa).erc20Infos(0);
    // }

    // function test_DepositERC20(uint96 _amount0, uint96 _amount1) public {
    //     vm.startPrank(user);
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     _mintTokens(address(userWallet), _amount0, _amount1);

    //     // construct calls
    //     Call[] memory calls = new Call[](4);

    //     // set token allowances
    //     calls[0] = (
    //         Call({
    //             to: address(token0),
    //             callData: abi.encodeWithSignature(
    //                 "approve(address,uint256)",
    //                 address(supa),
    //                 _amount0
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[1] = (
    //         Call({
    //             to: address(token1),
    //             callData: abi.encodeWithSignature(
    //                 "approve(address,uint256)",
    //                 address(supa),
    //                 _amount1
    //             ),
    //             value: 0
    //         })
    //     );

    //     // deposit erc20 tokens
    //     calls[2] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC20(address,uint256)",
    //                 token0,
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );

    //     calls[3] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC20(address,uint256)",
    //                 token1,
    //                 uint256(_amount1)
    //             ),
    //             value: 0
    //         })
    //     );

    //     // execute batch
    //     WalletLogic(address(userWallet)).executeBatch(calls);
    //     vm.stopPrank();
    // }

    // function test_depositERC20ForWallet(uint96 _amount0, uint96 _amount1) public {
    //     vm.startPrank(user);
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     vm.stopPrank();

    //     _mintTokens(address(this), _amount0, _amount1);

    //     // set allowances
    //     token0.approve(address(supa), _amount0);
    //     token1.approve(address(supa), _amount1);

    //     supa.depositERC20ForWallet(address(token0), address(userWallet), _amount0);
    //     supa.depositERC20ForWallet(address(token1), address(userWallet), _amount1);
    // }

    // /// @dev using uint96 to avoid arithmetic overflow in uint -> int conversion
    // function test_TransferERC20(uint96 _amount0) public {
    //     vm.startPrank(user);
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     WalletProxy userWallet2 = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

    //     // mint tokens to user's wallet
    //     token0.mint(address(userWallet), _amount0);

    //     // construct calls
    //     Call[] memory calls = new Call[](3);

    //     // set token allowances
    //     calls[0] = (
    //         Call({
    //             to: address(token0),
    //             callData: abi.encodeWithSignature(
    //                 "approve(address,uint256)",
    //                 address(supa),
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[1] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC20(address,uint256)",
    //                 token0,
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[2] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "transferERC20(address,address,uint256)",
    //                 token0,
    //                 address(userWallet2),
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );

    //     userWallet.executeBatch(calls);
    //     vm.stopPrank();
    // }

    // function test_DepositThenTransfer(uint96 _amount0) public {
    //     vm.startPrank(user);
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     WalletProxy userWallet2 = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

    //     // mint tokens to user's wallet
    //     token0.mint(address(userWallet), _amount0);

    //     // construct calls
    //     Call[] memory calls = new Call[](3);

    //     // set token allowances
    //     calls[0] = (
    //         Call({
    //             to: address(token0),
    //             callData: abi.encodeWithSignature(
    //                 "approve(address,uint256)",
    //                 address(supa),
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[1] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "transferERC20(address,address,uint256)",
    //                 token0,
    //                 address(userWallet2),
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[2] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC20(address,uint256)",
    //                 token0,
    //                 uint256(_amount0)
    //             ),
    //             value: 0
    //         })
    //     );

    //     userWallet.executeBatch(calls);
    //     vm.stopPrank();
    // }

    // function test_TransferMoreThanBalance(uint96 _amount, uint96 _extraAmount) public {
    //     vm.assume(_amount > 1 ether);
    //     vm.assume(_extraAmount > 1);
    //     WalletProxy otherWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     vm.startPrank(user);
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

    //     // mint tokens to user's wallet
    //     token0.mint(address(userWallet), _amount);

    //     // construct calls
    //     Call[] memory calls = new Call[](3);

    //     // set token allowances
    //     calls[0] = (
    //         Call({
    //             to: address(token0),
    //             callData: abi.encodeWithSignature(
    //                 "approve(address,uint256)",
    //                 address(supa),
    //                 uint256(_amount)
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[1] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC20(address,uint256)",
    //                 token0,
    //                 uint256(_amount)
    //             ),
    //             value: 0
    //         })
    //     );
    //     calls[2] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "transferERC20(address,address,uint256)",
    //                 token0,
    //                 address(otherWallet),
    //                 uint256(_amount) + uint256(_extraAmount)
    //             ),
    //             value: 0
    //         })
    //     );

    //     vm.expectRevert();
    //     userWallet.executeBatch(calls);
    //     vm.stopPrank();
    // }

    // function test_depositERC20IncreaseTokenCounter(uint256 amount) public {
    //     amount = bound(amount, 0, uint256(type(int256).max));
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     (, int256 tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //     assertEq(tokenCounter, 0);
    //     _mintTokens(address(this), amount, 0);
    //     token0.approve(address(supa), amount);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), amount);
    //     (, tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //     if (amount == 0) {
    //         assertEq(tokenCounter, 0);
    //     } else {
    //         assertEq(tokenCounter, 1);
    //     }
    // }

    // function test_depositERC20IncreaseTokenCounter2(uint256 amount) public {
    //     amount = bound(amount, 0, uint256(type(int256).max));
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     (, int256 tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //     assertEq(tokenCounter, 0);
    //     _mintTokens(address(this), amount, amount);
    //     token0.approve(address(supa), amount);
    //     token1.approve(address(supa), amount);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), amount);
    //     supa.depositERC20ForWallet(address(token1), address(userWallet), amount);
    //     (, tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //     if (amount == 0) {
    //         assertEq(tokenCounter, 0);
    //     } else {
    //         assertEq(tokenCounter, 2);
    //     }
    // }

    // function test_withdrawERC20DecreaseTokenCounter(uint256 amount) public {
    //     // NOTE: reverts with some amount > 2^96
    //     amount = bound(amount, 0, uint256(int256(type(int96).max)));
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     (, int256 tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //     assertEq(tokenCounter, 0);
    //     _mintTokens(address(this), amount, 0);
    //     token0.approve(address(supa), amount);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), amount);
    //     (, tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //     if (amount == 0) {
    //         assertEq(tokenCounter, 0);
    //     } else {
    //         assertEq(tokenCounter, 1);
    //         Call[] memory calls = new Call[](1);
    //         calls[0] = (
    //             Call({
    //                 to: address(supa),
    //                 callData: abi.encodeWithSignature(
    //                     "withdrawERC20(address,uint256)",
    //                     address(token0),
    //                     amount
    //                 ),
    //                 value: 0
    //             })
    //         );
    //         userWallet.executeBatch(calls);
    //         (, tokenCounter) = SupaState(supa).wallets(address(userWallet));
    //         assertEq(tokenCounter, 0);
    //     }
    // }

    // function test_depositERC721IncreaseNftCounter() public {
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     nft0Oracle.setPrice(0, 1 ether);
    //     uint256 nftCounter = SupaConfig(address(supa)).getCreditAccountERC721Counter(
    //         address(userWallet)
    //     );
    //     assertEq(nftCounter, 0);
    //     nft0.mint(address(userWallet));
    //     Call[] memory calls = new Call[](1);
    //     calls[0] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC721(address,uint256)",
    //                 address(nft0),
    //                 0
    //             ),
    //             value: 0
    //         })
    //     );
    //     userWallet.executeBatch(calls);
    //     nftCounter = SupaConfig(address(supa)).getCreditAccountERC721Counter(address(userWallet));
    //     assertEq(nftCounter, 1);
    // }

    // function test_withdrawERC721DecreaseNftCounter() public {
    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     nft0Oracle.setPrice(0, 1 ether);
    //     uint256 nftCounter = SupaConfig(address(supa)).getCreditAccountERC721Counter(
    //         address(userWallet)
    //     );
    //     assertEq(nftCounter, 0);
    //     nft0.mint(address(userWallet));
    //     Call[] memory calls = new Call[](1);
    //     calls[0] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC721(address,uint256)",
    //                 address(nft0),
    //                 0
    //             ),
    //             value: 0
    //         })
    //     );
    //     userWallet.executeBatch(calls);
    //     nftCounter = SupaConfig(address(supa)).getCreditAccountERC721Counter(address(userWallet));
    //     assertEq(nftCounter, 1);
    //     calls[0] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "withdrawERC721(address,uint256)",
    //                 address(nft0),
    //                 0
    //             ),
    //             value: 0
    //         })
    //     );
    //     userWallet.executeBatch(calls);
    //     nftCounter = SupaConfig(address(supa)).getCreditAccountERC721Counter(address(userWallet));
    //     assertEq(nftCounter, 0);
    // }

    // function test_exceedMaxTokenStorage() public {
    //     ISupaConfig(address(supa)).setTokenStorageConfig(
    //         ISupaConfig.TokenStorageConfig({
    //             maxTokenStorage: 100,
    //             erc20Multiplier: 100,
    //             erc721Multiplier: 1
    //         })
    //     );

    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     _mintTokens(address(this), 100 * 1 ether, 100 * 1 ether);
    //     token0.approve(address(supa), 100 * 1 ether);
    //     token1.approve(address(supa), 100 * 1 ether);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), 100 * 1 ether);
    //     vm.expectRevert(Supa.TokenStorageExceeded.selector);
    //     supa.depositERC20ForWallet(address(token1), address(userWallet), 100 * 1 ether);
    // }

    // function test_exceedMaxTokenStorageNFT() public {
    //     ISupaConfig(address(supa)).setTokenStorageConfig(
    //         ISupaConfig.TokenStorageConfig({
    //             maxTokenStorage: 1,
    //             erc20Multiplier: 1,
    //             erc721Multiplier: 1
    //         })
    //     );

    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     _mintTokens(address(this), 100 * 1 ether, 100 * 1 ether);
    //     token0.approve(address(supa), 100 * 1 ether);
    //     token1.approve(address(supa), 100 * 1 ether);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), 100 * 1 ether);

    //     nft0.mint(address(userWallet));
    //     Call[] memory calls = new Call[](1);
    //     calls[0] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC721(address,uint256)",
    //                 address(nft0),
    //                 0
    //             ),
    //             value: 0
    //         })
    //     );
    //     vm.expectRevert(Supa.TokenStorageExceeded.selector);
    //     userWallet.executeBatch(calls);
    // }

    // function test_increaseMaxTokenStorage() public {
    //     ISupaConfig(address(supa)).setTokenStorageConfig(
    //         ISupaConfig.TokenStorageConfig({
    //             maxTokenStorage: 100,
    //             erc20Multiplier: 100,
    //             erc721Multiplier: 1
    //         })
    //     );

    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     _mintTokens(address(this), 100 * 1 ether, 100 * 1 ether);
    //     token0.approve(address(supa), 100 * 1 ether);
    //     token1.approve(address(supa), 100 * 1 ether);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), 100 * 1 ether);
    //     vm.expectRevert(Supa.TokenStorageExceeded.selector);
    //     supa.depositERC20ForWallet(address(token1), address(userWallet), 100 * 1 ether);

    //     ISupaConfig(address(supa)).setTokenStorageConfig(
    //         ISupaConfig.TokenStorageConfig({
    //             maxTokenStorage: 250,
    //             erc20Multiplier: 1,
    //             erc721Multiplier: 1
    //         })
    //     );
    //     supa.depositERC20ForWallet(address(token1), address(userWallet), 100 * 1 ether);
    // }

    // function test_decreaseMaxTokenStorage() public {
    //     ISupaConfig(address(supa)).setTokenStorageConfig(
    //         ISupaConfig.TokenStorageConfig({
    //             maxTokenStorage: 100,
    //             erc20Multiplier: 10,
    //             erc721Multiplier: 1
    //         })
    //     );

    //     userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));
    //     _mintTokens(address(this), 100 * 1 ether, 100 * 1 ether);
    //     token0.approve(address(supa), 100 * 1 ether);
    //     token1.approve(address(supa), 100 * 1 ether);
    //     supa.depositERC20ForWallet(address(token0), address(userWallet), 100 * 1 ether);
    //     supa.depositERC20ForWallet(address(token1), address(userWallet), 100 * 1 ether);

    //     ISupaConfig(address(supa)).setTokenStorageConfig(
    //         ISupaConfig.TokenStorageConfig({
    //             maxTokenStorage: 10,
    //             erc20Multiplier: 10,
    //             erc721Multiplier: 1
    //         })
    //     );
    //     nft0.mint(address(userWallet));
    //     Call[] memory calls = new Call[](1);
    //     calls[0] = (
    //         Call({
    //             to: address(supa),
    //             callData: abi.encodeWithSignature(
    //                 "depositERC721(address,uint256)",
    //                 address(nft0),
    //                 0
    //             ),
    //             value: 0
    //         })
    //     );
    //     vm.expectRevert(Supa.TokenStorageExceeded.selector);
    //     userWallet.executeBatch(calls);
    // }

    // function _mintTokens(address to, uint256 amount0, uint256 amount1) internal {
    //     token0.mint(to, amount0);
    //     token1.mint(to, amount1);
    // }
}
