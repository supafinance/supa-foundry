# WalletState
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/wallet/WalletState.sol)

*the contract is abstract because it is not expected to be used separately from wallet*


## State Variables
### supa
*Supa instance to be used by all other wallet contracts*


```solidity
ISupa public supa;
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner();
```

### constructor


```solidity
constructor(address _supa);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_supa`|`address`|- address of a deployed Supa contract|


### updateSupa

Point the wallet to a new Supa contract

*This function is only callable by the wallet itself*


```solidity
function updateSupa(address _supa) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_supa`|`address`|- address of a deployed Supa contract|


