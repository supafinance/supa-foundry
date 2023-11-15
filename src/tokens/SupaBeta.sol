// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SupaBeta is ERC721, Ownable {

    bool public isLocked;

    /// @dev The address of the token descriptor contract, which handles generating token URIs for position tokens
    address private immutable _tokenDescriptor;

    constructor(
        address _tokenDescriptor_
    ) ERC721("SupaBeta", "SUPA") {
        _tokenDescriptor = _tokenDescriptor_;
    }

    function setLocked(bool _isLocked) external onlyOwner {
        isLocked = _isLocked;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(!isLocked, "SupaBeta: token transfers are locked");
        super.transferFrom(from, to, tokenId);
    }
}