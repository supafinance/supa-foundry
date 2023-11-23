// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BytesViewLib, TrieLib} from "../lib/Proofs.sol";

contract TestTrie {
    function verify(
        bytes calldata key,
        bytes32 root,
        bytes calldata proof
    ) external pure returns (bytes memory) {
        return BytesViewLib.toBytes(TrieLib.verify(bytes32(key), key.length, root, proof));
    }
}
