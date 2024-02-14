// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Supa, SupaState} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {GovernanceProxy} from "src/governance/GovernanceProxy.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";

import { WalletLogic } from "src/wallet/WalletLogic.sol";

import {MockERC20Oracle } from "src/testing/MockERC20Oracle.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

import {Execution, CallWithoutValue} from "src/lib/Call.sol";

contract SetupSupa is Script {
    function run() external {
        address payable supaAddress = payable(vm.envAddress("SUPA_ADDRESS"));

        uint256 chainId = block.chainid;
        address owner;
        if (chainId == 5) {
            owner = vm.envAddress("OWNER_GOERLI");
        } else if (chainId == 42161 || chainId == 8453) {
            owner = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }

        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        address offchainEntityProxyAddress = vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS");

        vm.startBroadcast(owner);

        WalletLogic walletLogic = new WalletLogic();

        VersionManager versionManager = VersionManager(address(IVersionManager(SupaState(supaAddress).versionManager())));
        console.log("versionManager", address(versionManager));
        SupaConfig supa = SupaConfig(supaAddress);

        GovernanceProxy governanceProxy = GovernanceProxy(governanceProxyAddress);

        assert(address(versionManager.immutableGovernance()) == address(governanceProxy));
        assert(address(supa.immutableGovernance()) == address(governanceProxy));

        // Setup configs
        ISupaConfig.Config memory config = ISupaConfig.Config({
            treasuryWallet: owner,
            treasuryInterestFraction: 0,
            maxSolvencyCheckGasCost: 1e6,
            liqFraction: 0.8 ether,
            fractionalReserveLeverage: 1
        });

        ISupaConfig.TokenStorageConfig memory tokenStorageConfig = ISupaConfig.TokenStorageConfig({
            maxTokenStorage: 200,
            erc20Multiplier: 1,
            erc721Multiplier: 5
        });

        CallWithoutValue[] memory governanceCalls = new CallWithoutValue[](2);
//        governanceCalls[0] = CallWithoutValue({
//            to: address(versionManager),
//            callData: abi.encodeWithSelector(VersionManager.addVersion.selector, IVersionManager.Status.PRODUCTION, address(walletLogic))
//        });
//        governanceCalls[1] = CallWithoutValue({
//            to: address(versionManager),
//            callData: abi.encodeWithSelector(VersionManager.markRecommendedVersion.selector, walletLogic.VERSION())
//        });
        governanceCalls[0] = CallWithoutValue({
            to: address(supa),
            callData: abi.encodeWithSelector(SupaConfig.setConfig.selector, config)
        });
        governanceCalls[1] = CallWithoutValue({
            to: address(supa),
            callData: abi.encodeWithSelector(SupaConfig.setTokenStorageConfig.selector, tokenStorageConfig)
        });


        OffchainEntityProxy offchainEntityProxy = OffchainEntityProxy(offchainEntityProxyAddress);

        Execution[] memory calls = new Execution[](1);
        calls[0] = Execution({
            target: address(governanceProxy),
            callData: abi.encodeWithSelector(GovernanceProxy.executeBatch.selector, governanceCalls),
            value: 0
        });
        offchainEntityProxy.executeBatch(calls);

        vm.stopBroadcast();
    }
}

// forge script script/SetupSupa.s.sol:SetupSupa --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer

// forge script script/SetupSupa.s.sol:SetupSupa --rpc-url $ARBITRUM_RPC_URL --broadcast -vvvv --account supa_deployer

// forge script script/SetupSupa.s.sol:SetupSupa --rpc-url $BASE_RPC_URL --broadcast -vvvv --account supa_deployer

