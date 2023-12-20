// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {WalletLogic} from "src/wallet/WalletLogic.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";
import {SupaState} from "src/supa/SupaState.sol";
import { GovernanceProxy } from "src/governance/GovernanceProxy.sol";
import { OffchainEntityProxy } from "src/governance/OffchainEntityProxy.sol";

import { CallWithoutValue, Call } from "src/lib/Call.sol";

contract CreateGovernanceSafeCalls is Script {
    function run() external {
        uint256 chainId = block.chainid;
        address deployer;
        if (chainId == 5) {
            deployer = vm.envAddress("DEPLOYER_GOERLI");
        } else if (chainId == 42161) {
            deployer = vm.envAddress("DEPLOYER");
        } else {
            revert("unsupported chain");
        }
        address versionManagerAddress = vm.envAddress("VERSION_MANAGER_ADDRESS");
        address governanceProxyAddress = vm.envAddress("GOVERNANCE_PROXY_ADDRESS");
        address offchainEntityProxyAddress = vm.envAddress("OFFCHAIN_ENTITY_PROXY_ADDRESS");

        address newWalletLogicAddress = 0x7B947Bf26E9906485d2f6c4ACF0ceD7E380e74a7;

        WalletLogic walletLogic = WalletLogic(newWalletLogicAddress);

        VersionManager versionManager = VersionManager(versionManagerAddress);

        GovernanceProxy governanceProxy = GovernanceProxy(governanceProxyAddress);
        OffchainEntityProxy offchainEntityProxy = OffchainEntityProxy(offchainEntityProxyAddress);

        CallWithoutValue[] memory governanceCalls = new CallWithoutValue[](2);

        governanceCalls[0] = CallWithoutValue({
            to: versionManagerAddress,
            callData: abi.encodeWithSelector(
                versionManager.addVersion.selector,
                IVersionManager.Status.PRODUCTION,
                newWalletLogicAddress
            )
        });
        governanceCalls[1] = CallWithoutValue({
            to: versionManagerAddress,
            callData: abi.encodeWithSelector(
                versionManager.markRecommendedVersion.selector,
                walletLogic.VERSION()
            )
        });

        Call[] memory offchainEntityCalls = new Call[](1);
        offchainEntityCalls[0] = Call({
            to: governanceProxyAddress,
            callData: abi.encodeWithSelector(
                governanceProxy.executeBatch.selector,
                governanceCalls
            ),
            value: 0
        });

        console.logBytes(abi.encodeWithSelector(offchainEntityProxy.executeBatch.selector, offchainEntityCalls));

    }
}

// forge script script/CreateGovernanceSafeCalls.s.sol:CreateGovernanceSafeCalls --rpc-url $GOERLI_RPC_URL -vvvv
// forge script script/CreateGovernanceSafeCalls.s.sol:CreateGovernanceSafeCalls --rpc-url $ARBITRUM_RPC_URL -vvvv