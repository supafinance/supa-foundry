# HashNFT
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/tokens/HashNFT.sol)

**Inherits:**
ERC1155Burnable

A generic ownerless contract that allows fine grained access control,
voting and other use cases build on top of.

*The 256 bit tokenId of ERC1155 is used to store cryptographic hash of the
an arbitrary digest and minter address. The cryptographic security of the hash
provides the guarantees of the contract.
1) Each token id is associated with only one minter and digest.
2) Ownership of a token id implies the minter has granted (directly or indirectly)
the ownership to the owner. (The minter can revoke the token at any time.
3) A minter (and only the minter) can revoke tokens it issued itself.
4) Everyone can burn tokens they own.*


## State Variables
### HASHNFT_TYPESTRING

```solidity
bytes constant HASHNFT_TYPESTRING = "HashNFT(address minter,bytes32 digest)";
```


### HASHNFT_TYPEHASH

```solidity
bytes32 constant HASHNFT_TYPEHASH = keccak256(HASHNFT_TYPESTRING);
```


## Functions
### constructor


```solidity
constructor(string memory uri) ERC1155(uri);
```

### mint


```solidity
function mint(address to, bytes32 digest, bytes calldata data) external returns (uint256 tokenId);
```

### revoke


```solidity
function revoke(address from, bytes32 digest) external;
```

### toTokenId


```solidity
function toTokenId(address minter, bytes32 digest) public pure returns (uint256);
```

## Events
### Minted

```solidity
event Minted(uint256 indexed tokenId, address indexed minter, bytes32 indexed digest);
```

