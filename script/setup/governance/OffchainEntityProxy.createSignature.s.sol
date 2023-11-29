// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {OffchainEntityProxy} from "src/governance/OffchainEntityProxy.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TransferOwnership is Script {

//    bytes32 private constant TAKEOWNERSHIP_TYPEHASH =
//    keccak256("TakeOwnership(address newOwner,uint256 nonce)");
//
//    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
//    uint256 private immutable _CACHED_CHAIN_ID;
//    address private immutable _CACHED_THIS;
//
//    bytes32 private immutable _HASHED_NAME;
//    bytes32 private immutable _HASHED_VERSION;
//    bytes32 private immutable _TYPE_HASH;
//
//    constructor() EIP712("OffchainEntityProxy", "1") {
//        _HASHED_NAME = keccak256(bytes("OffchainEntityProxy"));
//        _HASHED_VERSION = keccak256(bytes("1"));
//        bytes32 typeHash = keccak256(
//            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
//        );
//        _TYPE_HASH = typeHash;
//        _CACHED_CHAIN_ID = block.chainid;
//        _CACHED_THIS = address(this);
//        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
//    }

    function run() external {
        address governator = vm.envAddress("GOVERNATOR");
        address newOwner = vm.envAddress("OWNER");

//        bytes32 digest = _hashTypedDataV4(
//            keccak256(abi.encode(TAKEOWNERSHIP_TYPEHASH, newOwner, 0))
//        );

        vm.startBroadcast(governator);
//        vm.sign(governator, digest);
        vm.stopBroadcast();
    }

//    function _hashTypedDataV4(bytes32 structHash) public view virtual returns (bytes32) {
//        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
//    }
//
//    function _domainSeparatorV4() public view returns (bytes32) {
//        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
//            return _CACHED_DOMAIN_SEPARATOR;
//        } else {
//            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
//        }
//    }
//
//    function _buildDomainSeparator(
//        bytes32 typeHash,
//        bytes32 nameHash,
//        bytes32 versionHash
//    ) public view returns (bytes32) {
//        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
//    }
}

// forge script script/deploy/governance/OffchainEntityProxy.s.sol:DeployOffchainEntityProxy --rpc-url $GOERLI_RPC_URL --broadcast -vvvv --account supa_test_deployer --trezor
