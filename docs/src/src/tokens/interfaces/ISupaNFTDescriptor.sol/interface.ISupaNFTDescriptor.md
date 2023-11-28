# ISupaNFTDescriptor
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/tokens/interfaces/ISupaNFTDescriptor.sol)

This contract generates the URI describing the Supa NFTs.

*Inspired by Uniswap V3 Positions NFTs & SablierV2 stream NFTs.*


## Functions
### tokenURI

Produces the URI describing a particular stream NFT.

*This is a data URI with the JSON contents directly inlined.*


```solidity
function tokenURI(IERC721Metadata sablier, uint256 streamId) external view returns (string memory uri);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sablier`|`IERC721Metadata`|The address of the Sablier contract the stream was created in.|
|`streamId`|`uint256`|The id of the stream for which to produce a description.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The URI of the ERC721-compliant metadata.|


