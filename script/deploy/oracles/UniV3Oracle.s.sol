// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {UniV3Oracle} from "src/oracles/UniV3Oracle.sol";

contract DeployUniV3Oracle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address manager = vm.envAddress("NONFUNGIBLE_POSITION_MANAGER");
        address factory = vm.envAddress("UNISWAP_V3_FACTORY");
        address owner = vm.envAddress("OWNER");

        address usdc = vm.envAddress("USDC_GOERLI");
        address usdcOracle = vm.envAddress("USDC_ORACLE");
        address weth = vm.envAddress("WETH_GOERLI");
        address wethOracle = vm.envAddress("WETH_TWAP");
        address uni = vm.envAddress("UNI");
        address uniOracle = vm.envAddress("UNI_ORACLE");

        vm.startBroadcast(deployerPrivateKey);
        UniV3Oracle uniV3Oracle = new UniV3Oracle(factory, manager, owner);
        uniV3Oracle.setERC20ValueOracle(usdc, usdcOracle);
        uniV3Oracle.setERC20ValueOracle(weth, wethOracle);
        uniV3Oracle.setERC20ValueOracle(uni, uniOracle);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/oracles/UniV3Oracle.s.sol:DeployUniV3Oracle --rpc-url $GOERLI_RPC_URL --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv
