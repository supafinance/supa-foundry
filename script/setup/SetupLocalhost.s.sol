// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic} from "src/wallet/WalletLogic.sol";

import {WETH9} from "src/testing/external/WETH9.sol";
import {TestERC20} from "src/testing/TestERC20.sol";
import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {INonfungiblePositionManager} from "src/external/interfaces/INonfungiblePositionManager.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {TransferAndCall2} from "src/supa/TransferAndCall2.sol";

contract SetupLocalHost is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factoryAddress = vm.envAddress("UNISWAP_V3_FACTORY");
        address routerAddress = vm.envAddress("SWAP_ROUTER");
        address owner = vm.envAddress("OWNER");

        vm.startBroadcast(deployerPrivateKey);

        // deploy localhost environment
        WETH9 weth = new WETH9();
        TestERC20 usdc = new TestERC20("USDC", "USDC", 6);
        TestERC20 uni = new TestERC20("UNI", "UNI", 18);

        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        ISwapRouter router = ISwapRouter(routerAddress);
        INonfungiblePositionManager nftManager = INonfungiblePositionManager(manager);

        SupaConfig supaConfig = new SupaConfig(owner);
        VersionManager versionManager = new VersionManager(owner);
        Supa supa = new Supa(address(supaConfig), address(versionManager));
        TransferAndCall2 transferAndCall2 = new TransferAndCall2();

        WalletLogic walletLogic = new WalletLogic();

        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(walletLogic));
        versionManager.markRecommendedVersion("1.0.0");

        // setupSupa
        MockERC20Oracle usdcOracle = new MockERC20Oracle(owner);
        usdcOracle.setPrice(1 ether, 6, 18);

        MockERC20Oracle uniOracle = new MockERC20Oracle(owner);
        uniOracle.setPrice(840 ether, 6, 18);

        MockERC20Oracle wethOracle = new MockERC20Oracle(owner);
        wethOracle.setPrice(1200 ether, 6, 18);

        UniV3Oracle uniV3Oracle = new UniV3Oracle(address(factory), address(nftManager), address(owner));

        ISupaConfig.Config memory config = ISupaConfig.Config({
            treasuryWallet: owner,
            treasuryInterestFraction: 0.05 ether,
            maxSolvencyCheckGasCost: 1e6,
            liqFraction: 0.8 ether,
            fractionalReserveLeverage: 9
        });

        ISupaConfig.TokenStorageConfig memory tokenStorageConfig =
            ISupaConfig.TokenStorageConfig({maxTokenStorage: 100, erc20Multiplier: 1, erc721Multiplier: 5});

        supaConfig.setConfig(config);
        supaConfig.setTokenStorageConfig(tokenStorageConfig);

        supaConfig.addERC20Info(address(usdc), "USDC", "USDC", 6, address(usdcOracle), 0, 5, 480, 0.8 ether);
        supaConfig.addERC20Info(address(uni), "UNI", "UNI", 18, address(uniOracle), 0, 5, 480, 0.8 ether);
        supaConfig.addERC20Info(address(weth), "WETH", "WETH", 18, address(wethOracle), 0, 5, 480, 0.8 ether);

        uniV3Oracle.setERC20ValueOracle(address(usdc), address(usdcOracle));
        uniV3Oracle.setERC20ValueOracle(address(uni), address(uniOracle));
        uniV3Oracle.setERC20ValueOracle(address(weth), address(wethOracle));

        usdc.mint(owner, 1_000_000 * 1e6);
        uni.mint(owner, 1_000_000 ether);

        usdc.approve(address(router), type(uint256).max);
        uni.approve(address(router), type(uint256).max);
        weth.approve(address(router), type(uint256).max);

        usdc.approve(address(nftManager), type(uint256).max);
        uni.approve(address(nftManager), type(uint256).max);
        weth.approve(address(nftManager), type(uint256).max);

        usdc.approve(address(transferAndCall2), type(uint256).max);
        uni.approve(address(transferAndCall2), type(uint256).max);
        weth.approve(address(transferAndCall2), type(uint256).max);

        bytes memory managerBytecode = vm.envBytes("NONFUNGIBLE_POSITION_MANAGER_BYTECODE");
        bytes memory factoryBytecode = vm.envBytes("UNISWAP_V3_FACTORY_BYTECODE");
        bytes memory routerBytecode = vm.envBytes("SWAP_ROUTER");

        vm.etch(address(nftManager), managerBytecode);
        vm.etch(address(factory), factoryBytecode);
        vm.etch(address(router), routerBytecode);
        vm.stopBroadcast();
    }
}

// forge script script/setup/SetupLocalHost.s.sol:SetupLocalHost --rpc-url http://localhost:8545 --broadcast -vvvv
