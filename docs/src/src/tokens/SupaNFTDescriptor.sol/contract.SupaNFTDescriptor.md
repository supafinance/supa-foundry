# SupaNFTDescriptor
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/tokens/SupaNFTDescriptor.sol)

**Inherits:**
[ISupaNFTDescriptor](/src/tokens/interfaces/ISupaNFTDescriptor.sol/interface.ISupaNFTDescriptor.md)

See the documentation in {ISupaNFTDescriptor}.


## Functions
### tokenURI

Produces the URI describing a particular stream NFT.

*This is a data URI with the JSON contents directly inlined.*


```solidity
function tokenURI(IERC721Metadata sablier, uint256 streamId) external view override returns (string memory uri);
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


### generateAccentColor

Generates a pseudo-random HSL color by hashing together the `chainid`, the `sablier` address,
and the `streamId`. This will be used as the accent color for the SVG.


```solidity
function generateAccentColor(address owner, uint256 streamId) internal view returns (string memory);
```

## Structs
### TokenURIVars
*Needed to avoid Stack Too Deep.*


```solidity
struct TokenURIVars {
    address asset;
    string assetSymbol;
    string json;
    string sablierAddress;
    string status;
    string svg;
}
```

