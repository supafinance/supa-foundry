# GovernanceProxy
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/governance/GovernanceProxy.sol)


## State Variables
### governance

```solidity
address public governance;
```


### proposedGovernance

```solidity
address public proposedGovernance;
```


## Functions
### constructor


```solidity
constructor(address _governance);
```

### executeBatch

Execute a batch of contract calls.


```solidity
function executeBatch(CallWithoutValue[] calldata calls) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`CallWithoutValue[]`|an array of calls.|


### proposeGovernance

Propose a new account as governance account. Note that this can
only be called through the execute method above and hence only
by the current governance.


```solidity
function proposeGovernance(address newGovernance) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newGovernance`|`address`|address of the new governance account (or zero to revoke proposal)|


## Events
### NewGovernanceProposed

```solidity
event NewGovernanceProposed(address newGovernance);
```

### GovernanceChanged

```solidity
event GovernanceChanged(address oldGovernance, address newGovernance);
```

### BatchExecuted

```solidity
event BatchExecuted(CallWithoutValue[] calls);
```

## Errors
### OnlyGovernance

```solidity
error OnlyGovernance();
```

