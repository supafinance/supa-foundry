// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";

import {GelatoOperator} from "src/periphery/GelatoOperator.sol";

import {WalletProxy} from "src/wallet/WalletProxy.sol";
import {TaskCreator} from "src/gelato/TaskCreator.sol";
import {TaskCreatorProxy} from "src/gelato/TaskCreatorProxy.sol";
import {Supa} from "src/supa/Supa.sol";
import {SupaConfig, ISupaConfig} from "src/supa/SupaConfig.sol";
import {VersionManager, IVersionManager} from "src/supa/VersionManager.sol";

import {WalletLogic, LinkedCall, ReturnDataLink} from "src/wallet/WalletLogic.sol";
import {WalletProxy} from "src/wallet/WalletProxy.sol";

import {Call, CallLib} from "src/lib/Call.sol";

contract GelatoTest is Test {
    GelatoOperator public gelatoOperator;
    WalletProxy public walletProxy;
    TaskCreator public taskCreator;
    TaskCreatorProxy public taskCreatorProxy;
    address public automate = 0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0;
    VersionManager public versionManager;
    SupaConfig public supaConfig;
    Supa public supa;

    WalletLogic public proxyLogic;
    WalletProxy public userWallet;

    string public constant VERSION = "1.0.0";

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");


    function setUp() public {
        // fork mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        address dedicatedSender = address(this);
        address owner = address(this);
        gelatoOperator = new GelatoOperator(dedicatedSender);

        versionManager = new VersionManager(owner);
        supaConfig = new SupaConfig(owner);
        supa = new Supa(address(supaConfig), address(versionManager));
        proxyLogic = new WalletLogic(address(supa));

        ISupaConfig(address(supa)).setConfig(
            ISupaConfig.Config({
                treasuryWallet: address(0),
                treasuryInterestFraction: 0,
                maxSolvencyCheckGasCost: 10_000_000,
                liqFraction: 8e17,
                fractionalReserveLeverage: 10
            })
        );

        versionManager.addVersion(IVersionManager.Status.PRODUCTION, address(proxyLogic));
        versionManager.markRecommendedVersion(VERSION);

        taskCreatorProxy = new TaskCreatorProxy();
        taskCreator = new TaskCreator(address(supa), address(automate));

    }

    // function testAddOperator() public {
    //     address target = address(this);
    //     walletProxy.addOperator(target);
    // }

    function testDedicatedSender() public {
        address dedicatedSender = address(this);
        assertEq(gelatoOperator.dedicatedSender(), dedicatedSender);
    }

    function testProxy() public {
        string memory cid = 'QmPtdg15JttHPzV592jy1AhjoByTAE8tCeTFRYjLMjAExk';
        userWallet = WalletProxy(payable(ISupaConfig(address(supa)).createWallet()));

        Call[] memory calls = new Call[](1);
        calls[0] = Call({
            to: address(taskCreatorProxy),
            callData: abi.encodeWithSignature("createTask(uint256,string)", 0, cid),
            value: 0
        });
        userWallet.executeBatch(calls);
    }

    // function testExecute() public {
    //     address target = address(this);
    //     Call[] memory calls = new Call[](0);
    //     gelatoOperator.execute(target, calls);
    // }
}
