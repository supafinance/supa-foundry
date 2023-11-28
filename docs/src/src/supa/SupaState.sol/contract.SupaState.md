# SupaState
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/supa/SupaState.sol)

**Inherits:**
Pausable

Contract holds the configuration state for Supa


## State Variables
### versionManager

```solidity
IVersionManager public versionManager;
```


### wallets
mapping between wallet address and Supa-specific wallet data


```solidity
mapping(address => WalletLib.Wallet) public wallets;
```


### walletNonce
mapping between account and their nonce for wallet creation


```solidity
mapping(address account => uint256 nonce) public walletNonce;
```


### walletProposedNewOwner
mapping between wallet address and the proposed new owner

*`proposedNewOwner` is address(0) when there is no pending change*


```solidity
mapping(address => address) public walletProposedNewOwner;
```


### walletLogic
mapping between wallet address and an instance of deployed walletLogic contract.
It means that this specific walletLogic version is setup to operate the wallet.


```solidity
mapping(address => address) public walletLogic;
```


### allowances
mapping from
wallet owner address => ERC20 address => wallet spender address => allowed amount of ERC20.
It represent the allowance of `spender` to transfer up to `amount` of `erc20` balance of
owner's creditAccount to some other creditAccount. E.g. 123 => abc => 456 => 1000, means that
wallet 456 can transfer up to 1000 of abc tokens from creditAccount of wallet 123 to some other creditAccount.
Note, that no ERC20 are actually getting transferred - creditAccount is a Supa concept, and
corresponding tokens are owned by Supa


```solidity
mapping(address => mapping(address => mapping(address => uint256))) public allowances;
```


### operatorApprovals
Whether a spender is approved to operate on behalf of an owner

*Mapping from wallet owner address => spender address => bool*


```solidity
mapping(address => mapping(address => bool)) public operatorApprovals;
```


### tokenDataByNFTId

```solidity
mapping(WalletLib.NFTId => NFTTokenData) public tokenDataByNFTId;
```


### erc20Infos

```solidity
ERC20Info[] public erc20Infos;
```


### erc721Infos

```solidity
ERC721Info[] public erc721Infos;
```


### infoIdx
mapping of ERC20 or ERC721 address => Supa asset idx and contract kind.
idx is the index of the ERC20 in `erc20Infos` or ERC721 in `erc721Infos`
kind is ContractKind enum, that here can be ERC20 or ERC721


```solidity
mapping(address => ContractData) public infoIdx;
```


### config

```solidity
ISupaConfig.Config public config;
```


### tokenStorageConfig

```solidity
ISupaConfig.TokenStorageConfig public tokenStorageConfig;
```


## Functions
### onlyWallet


```solidity
modifier onlyWallet();
```

### walletExists


```solidity
modifier walletExists(address wallet);
```

### getBalance


```solidity
function getBalance(ERC20Share shares, ERC20Info storage erc20Info) internal view returns (int256);
```

### getNFTData


```solidity
function getNFTData(WalletLib.NFTId nftId) internal view returns (uint16 erc721Idx, uint256 tokenId);
```

### getERC20Info


```solidity
function getERC20Info(IERC20 erc20) internal view returns (ERC20Info storage, uint16);
```

