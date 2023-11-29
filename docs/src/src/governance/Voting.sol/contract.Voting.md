# Voting
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/governance/Voting.sol)

**Inherits:**
EIP712


## State Variables
### VOTE_TYPESTRING

```solidity
bytes private constant VOTE_TYPESTRING = "Vote(uint256 proposalId,bool support)";
```


### VOTE_TYPEHASH

```solidity
bytes32 private constant VOTE_TYPEHASH = keccak256(VOTE_TYPESTRING);
```


### FRACTION

```solidity
uint256 public constant FRACTION = 10;
```


### MIN_VOTING_POWER

```solidity
uint256 public constant MIN_VOTING_POWER = 100 ether;
```


### hashNFT

```solidity
HashNFT public immutable hashNFT;
```


### governanceToken

```solidity
address public immutable governanceToken;
```


### governance

```solidity
address public immutable governance;
```


### mappingSlot

```solidity
uint256 public immutable mappingSlot;
```


### totalSupplySlot

```solidity
uint256 public immutable totalSupplySlot;
```


### proposals

```solidity
Proposal[] public proposals;
```


### votesByAddress

```solidity
mapping(address => NonceMap) private votesByAddress;
```


### delegates

```solidity
mapping(address => address) public delegates;
```


## Functions
### requireValidProposal


```solidity
modifier requireValidProposal(uint256 proposalId);
```

### constructor


```solidity
constructor(
    address hashNFT_,
    address governanceToken_,
    uint256 mappingSlot_,
    uint256 totalSupplySlot_,
    address governance_
) EIP712("Voting", "1");
```

### proposeVote


```solidity
function proposeVote(
    string calldata title,
    string calldata description,
    CallWithoutValue[] calldata calls,
    uint256 blockNumber,
    bytes calldata blockHeader,
    bytes calldata stateProof,
    bytes calldata totalSupplyProof,
    address voter,
    bytes calldata proof
) external;
```

### vote


```solidity
function vote(address voter, uint256 proposalId, bool support, bytes calldata proof)
    external
    requireValidProposal(proposalId);
```

### voteBatch


```solidity
function voteBatch(uint256 proposalId, Vote[] calldata votes) external requireValidProposal(proposalId);
```

### resolve


```solidity
function resolve(uint256 proposalId) external;
```

### setDelegate


```solidity
function setDelegate(address delegate) external;
```

### hasVoted


```solidity
function hasVoted(address voter, uint256 proposalId) external view returns (bool);
```

### _vote


```solidity
function _vote(address addr, uint256 proposalId, bool support, bytes calldata proof)
    internal
    returns (uint256 amount);
```

### getBlockHash

*Override this function for testing to return handcrafted blockhashes*


```solidity
function getBlockHash(uint256 blockNumber) internal view virtual returns (bytes32 blockHash);
```

## Events
### ProposalCreated

```solidity
event ProposalCreated(
    uint256 proposalId,
    string title,
    string description,
    CallWithoutValue[] calls,
    uint256 deadline,
    bytes32 digest,
    uint256 blockNumber
);
```

### VoteCasted

```solidity
event VoteCasted(address voter, uint256 proposalId, bool support, uint256 votes);
```

## Structs
### Proposal

```solidity
struct Proposal {
    bytes32 digest;
    uint256 deadline;
    bytes32 storageHash;
    uint256 totalSupply;
    uint256 yesVotes;
    uint256 noVotes;
}
```

### Vote

```solidity
struct Vote {
    address voter;
    bool support;
    bytes signature;
    bytes proof;
}
```

