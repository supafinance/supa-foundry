// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import { WalletLogic } from "src/wallet/WalletLogic.sol";

import {MockERC20Oracle } from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract SetupSupa is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER");
        address payable supaAddress = payable(vm.envAddress("SUPA"));
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");

        address usdc = vm.envAddress("USDC");
        address weth = vm.envAddress("WETH");
        address uni = vm.envAddress("UNI");

        address usdcOracleAddress = vm.envAddress("USDC_ORACLE");
        address wethOracleAddress = vm.envAddress("ETH_ORACLE");
        address uniOracleAddress = vm.envAddress("UNI_ORACLE");


        vm.startBroadcast(deployerPrivateKey);

        WalletLogic walletLogic = new WalletLogic(supaAddress);

        VersionManager versionManager = VersionManager(address(IVersionManager(SupaState(supaAddress).versionManager())));
        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(walletLogic));
        versionManager.markRecommendedVersion("1.0.0");

        // Deploy + setup token oracles
        MockERC20Oracle usdcOracle = new MockERC20Oracle(owner);
        usdcOracle.setPrice(1 ether, 6, 18);
        usdcOracle.setRiskFactors(0.95 ether, 0.95 ether);
        MockERC20Oracle ethOracle = new MockERC20Oracle(owner);
        ethOracle.setPrice(1200 ether, 6, 18);
        ethOracle.setRiskFactors(0.95 ether, 0.95 ether);
        MockERC20Oracle uniOracle = new MockERC20Oracle(owner);
        uniOracle.setPrice(200 ether, 6, 18);
        uniOracle.setRiskFactors(0.95 ether, 0.95 ether);
        UniV3Oracle uniV3Oracle = new UniV3Oracle(factory, manager, owner);

        // Setup configs
        ISupaConfig.Config memory config = ISupaConfig.Config({
            treasuryWallet: owner, 
            treasuryInterestFraction: 0.05 ether,
            maxSolvencyCheckGasCost: 1e6,
            liqFraction: 0.8 ether,
            fractionalReserveLeverage: 9
        });

        ISupaConfig.TokenStorageConfig memory tokenStorageConfig = ISupaConfig.TokenStorageConfig({
            maxTokenStorage: 200,
            erc20Multiplier: 1,
            erc721Multiplier: 5
        });

        SupaConfig supa = SupaConfig(supaAddress);
        supa.setConfig(config);
        supa.setTokenStorageConfig(tokenStorageConfig);


        // Add ERC20s
        supa.addERC20Info(weth, "Wrapped Ether", "WETH", 18, address(ethOracle), 0, 5, 480, 0.8 ether);
        supa.addERC20Info(usdc, "USD Coin", "USDC", 6, address(usdcOracle), 0, 5, 480, 0.8 ether);
        supa.addERC20Info(uni, "Uniswap", "UNI", 18, address(uniOracle), 0, 5, 480, 0.8 ether);
        supa.addERC721Info(manager, address(uniV3Oracle));
        uniV3Oracle.setERC20ValueOracle(weth, address(ethOracle));
        uniV3Oracle.setERC20ValueOracle(usdc, address(usdcOracle));
        uniV3Oracle.setERC20ValueOracle(uni, address(uniOracle));

        vm.stopBroadcast();
    }
}

// forge script script/SetupSupa.s.sol:SetupSupa --rpc-url $GOERLI_RPC_URL --broadcast -vvvv

// forge script script/SetupSupa.s.sol:SetupSupa --rpc-url $POLYGON_RPC_URL --broadcast -vvvv

