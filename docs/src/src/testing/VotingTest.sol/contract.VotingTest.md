# VotingTest
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/VotingTest.sol)

**Inherits:**
[Voting](/src/governance/Voting.sol/contract.Voting.md)


## State Variables
### mockBlockHash

```solidity
bytes32 public mockBlockHash;
```


## Functions
### constructor


```solidity
constructor(
    address hashNFT_,
    address governanceToken_,
    uint256 mappingSlot_,
    uint256 totalSupplySlot_,
    address governance_
) Voting(hashNFT_, governanceToken_, mappingSlot_, totalSupplySlot_, governance_);
```

### setMockBlockHash


```solidity
function setMockBlockHash(bytes32 blockHash) external;
```

### getBlockHash


```solidity
function getBlockHash(uint256) internal view override returns (bytes32);
```

