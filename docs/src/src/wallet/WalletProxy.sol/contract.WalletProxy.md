# WalletProxy
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/wallet/WalletProxy.sol)

**Inherits:**
[WalletState](/src/wallet/WalletState.sol/abstract.WalletState.md), Proxy

Proxy contract for Supa Wallets


## Functions
### ifSupa


```solidity
modifier ifSupa();
```

### constructor


```solidity
constructor(address _supa) WalletState(_supa);
```

### receive

*Allow ETH transfers*


```solidity
receive() external payable override;
```

### executeBatch


```solidity
function executeBatch(Call[] calldata calls) external payable ifSupa;
```

### _implementation


```solidity
function _implementation() internal view override returns (address);
```

