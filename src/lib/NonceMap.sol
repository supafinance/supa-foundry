// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

struct NonceMap {
    BitMaps.BitMap bitMap;
}

library NonceMapLib {
    using BitMaps for BitMaps.BitMap;

    function validateAndUseNonce(NonceMap storage self, uint256 nonce) internal {
        require(!self.bitMap.get(nonce), "Nonce already used");
        self.bitMap.set(nonce);
    }

    function getNonce(NonceMap storage self, uint256 nonce) internal view returns (bool) {
        return self.bitMap.get(nonce);
    }
}
