# TimeLockedCall
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/governance/TimeLockedCall.sol)

**Inherits:**
[ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md), Ownable2Step


## State Variables
### MIN_TIMELOCK

```solidity
uint256 constant MIN_TIMELOCK = 1 days;
```


### MAX_TIMELOCK

```solidity
uint256 constant MAX_TIMELOCK = 3 days;
```


### hashNFT

```solidity
HashNFT public immutable hashNFT;
```


### accessLevel

```solidity
uint8 public immutable accessLevel;
```


### lockTime

```solidity
uint256 public lockTime;
```


## Functions
### constructor


```solidity
constructor(address governance, address hashNFT_, uint8 _accessLevel, uint256 _lockTime)
    ImmutableGovernance(governance);
```

### proposeBatch


```solidity
function proposeBatch(CallWithoutValue[] calldata calls) external onlyOwner;
```

### executeBatch


```solidity
function executeBatch(CallWithoutValue[] calldata calls, uint256 executionTime) external;
```

### setLockTime


```solidity
function setLockTime(uint256 _lockTime) external onlyGovernance;
```

### _setLockTime


```solidity
function _setLockTime(uint256 _lockTime) internal;
```

### calcDigest


```solidity
function calcDigest(CallWithoutValue[] calldata calls, uint256 executionTime) internal pure returns (bytes32);
```

## Events
### BatchProposed

```solidity
event BatchProposed(CallWithoutValue[] calls, uint256 executionTime);
```

