// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ERC20TwapOracle} from "src/oracles/ERC20TwapOracle.sol";

contract SetOracleRiskFactors is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");

        address wethOracleAddress = vm.envAddress("WETH_TWAP");
        address uniOracleAddress = vm.envAddress("UNI_ORACLE");
        address usdcOracleAddress = vm.envAddress("USDC_ORACLE");

        ERC20TwapOracle wethOracle = ERC20TwapOracle(wethOracleAddress);

        ERC20TwapOracle uniOracle = ERC20TwapOracle(uniOracleAddress);
        ERC20TwapOracle usdcOracle = ERC20TwapOracle(usdcOracleAddress);

        vm.startBroadcast(deployerPrivateKey);
        // uniOracle.setRiskFactors(0.7 ether, 0.7 ether);
        usdcOracle.setRiskFactors(0.9 ether, 0.9 ether);
        // wethOracle.setRiskFactors(0.9 ether, 0.9 ether);
        vm.stopBroadcast();
    }
}

// forge script script/setup/setOracleRiskFactors.s.sol:SetOracleRiskFactors --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
