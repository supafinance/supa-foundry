# SupaBeta
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/tokens/SupaBeta.sol)

**Inherits:**
ERC721, Ownable


## State Variables
### isLocked

```solidity
bool public isLocked;
```


### _tokenCounter

```solidity
uint256 private _tokenCounter;
```


## Functions
### constructor


```solidity
constructor() ERC721("SupaBeta", "SUPA");
```

### mint


```solidity
function mint(address to) external onlyOwner;
```

### setLocked


```solidity
function setLocked(bool _isLocked) external onlyOwner;
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 tokenId) public override;
```

### tokenURI


```solidity
function tokenURI(uint256 tokenId) public view override returns (string memory);
```

### generateAccentColor

Generates a pseudo-random HSL color by hashing together the `chainid`, the `sablier` address,
and the `streamId`. This will be used as the accent color for the SVG.


```solidity
function generateAccentColor(address owner, uint256 streamId) internal view returns (string memory);
```

## Errors
### Locked

```solidity
error Locked();
```

