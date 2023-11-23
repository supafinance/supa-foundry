// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Supa} from "src/supa/Supa.sol";
import {SupaConfig} from "src/supa/SupaConfig.sol";
import {MockERC20Oracle} from "src/testing/MockERC20Oracle.sol";

contract DeployMockERC20Oracle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address supa = vm.envAddress("SUPA");
        address usdcAddress = vm.envAddress("USDC");
        address wethAddress = vm.envAddress("WETH");
        address uniAddress = vm.envAddress("UNI");
        address owner = vm.envAddress("OWNER");

        vm.startBroadcast(deployerPrivateKey);
        MockERC20Oracle usdcOracle = new MockERC20Oracle(owner);
        // MockERC20Oracle wethOracle = new MockERC20Oracle(owner);
        // MockERC20Oracle uniOracle = new MockERC20Oracle(owner);

        SupaConfig supaConfig = SupaConfig(supa);
        supaConfig.setERC20Data(usdcAddress, address(usdcOracle), 0, 5, 480, 0.8 ether);
        // supaConfig.setERC20Data(wethAddress, address(wethOracle), 0, 5, 480, 0.8 ether);
        // supaConfig.setERC20Data(uniAddress, address(uniOracle), 0, 5, 480, 0.8 ether);
        vm.stopBroadcast();
    }
}

// forge script script/deploy/test/MockERC20Oracle.s.sol:DeployMockERC20Oracle --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
