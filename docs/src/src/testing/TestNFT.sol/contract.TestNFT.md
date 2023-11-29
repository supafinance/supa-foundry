# TestNFT
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/TestNFT.sol)

**Inherits:**
ERC721


## State Variables
### tokenIdCounter

```solidity
Counters.Counter private tokenIdCounter;
```


## Functions
### constructor


```solidity
constructor(string memory name, string memory symbol, uint256 initTokenId) ERC721(name, symbol);
```

### mint


```solidity
function mint(address to) public returns (uint256);
```

## Events
### Mint

```solidity
event Mint(uint256 tokenId);
```

