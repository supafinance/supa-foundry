// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;// SPDX-License-Identifier:// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17; MIT
pragma solidity ^0.8.17;
import {Script, console} from "forge-std/Script.sol";

import {Supa} from "src/supa/Supa.sol";

contract GetWalletVersion is Script {
    function run() external {
        address walletAddress = 0x03D5e2c60a3fEe4b96f67d110C6495f41f250F43;

        address supaAddress = vm.envAddress("SUPA");

        Supa supa = Supa(payable(supaAddress));
        address version = supa.getImplementation(walletAddress);
    }
}

// forge script script/data/getWalletVersion.s.sol:GetWalletVersion --rpc-url $GOERLI_RPC_URL --broadcast -vvvv
// 0x6276630eBD6CB83d220A8eBb2DaD790758F945a7