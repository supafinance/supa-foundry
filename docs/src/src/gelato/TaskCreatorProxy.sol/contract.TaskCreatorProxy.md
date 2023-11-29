# TaskCreatorProxy
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/TaskCreatorProxy.sol)

**Inherits:**
Proxy, Ownable


## State Variables
### _IMPLEMENTATION_SLOT
*Storage slot with the address of the current implementation.
This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
validated in the constructor.*


```solidity
bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
```


## Functions
### upgrade


```solidity
function upgrade(address implementation_) external onlyOwner;
```

### implementation


```solidity
function implementation() external view returns (address);
```

### _setImplementation


```solidity
function _setImplementation(address newImplementation) private;
```

### _implementation


```solidity
function _implementation() internal view override returns (address);
```

