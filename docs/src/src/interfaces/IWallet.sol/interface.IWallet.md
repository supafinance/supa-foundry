# IWallet
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/IWallet.sol)


## Functions
### executeBatch

makes a batch of different calls from the name of wallet owner. Eventual state of
creditAccount and Supa must be solvent, i.e. debt on creditAccount cannot exceed collateral on
creditAccount and wallet and Supa reserve/debt must be sufficient

*- this goes to supa.executeBatch that would immediately call WalletProxy.executeBatch
from above of this file*


```solidity
function executeBatch(Call[] memory calls) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`calls`|`Call[]`|{address to, bytes callData, uint256 value}[], where * to - is the address of the contract whose function should be called * callData - encoded function name and it's arguments * value - the amount of ETH to sent with the call|


## Events
### TokensApproved

```solidity
event TokensApproved(address sender, uint256 amount, bytes data);
```

### TokensReceived

```solidity
event TokensReceived(address spender, address sender, uint256 amount, bytes data);
```

