# ISupaConfig
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/ISupa.sol)


## Functions
### upgradeWalletImplementation

upgrades the version of walletLogic contract for the `wallet`


```solidity
function upgradeWalletImplementation(string calldata version) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`version`|`string`|The new target version of walletLogic contract|


### proposeTransferWalletOwnership

Proposes the ownership transfer of `wallet` to the `newOwner`

*The ownership transfer must be executed by the `newOwner` to complete the transfer*

*emits `WalletOwnershipTransferProposed` event*


```solidity
function proposeTransferWalletOwnership(address newOwner) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`|The new owner of the `wallet`|


### executeTransferWalletOwnership

Executes the ownership transfer of `wallet` to the `newOwner`

*The caller must be the `newOwner` and the `newOwner` must be the proposed new owner*

*emits `WalletOwnershipTransferred` event*


```solidity
function executeTransferWalletOwnership(address wallet) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|


### addERC20Info

add a new ERC20 to be used inside Supa

*For governance only.*


```solidity
function addERC20Info(
    address erc20Contract,
    string calldata name,
    string calldata symbol,
    uint8 decimals,
    address valueOracle,
    uint256 baseRate,
    uint256 slope1,
    uint256 slope2,
    uint256 targetUtilization
) external returns (uint16);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20Contract`|`address`|The address of ERC20 to add|
|`name`|`string`|The name of the ERC20. E.g. "Wrapped ETH"|
|`symbol`|`string`|The symbol of the ERC20. E.g. "WETH"|
|`decimals`|`uint8`|Decimals of the ERC20. E.g. 18 for WETH and 6 for USDC|
|`valueOracle`|`address`|The address of the Value Oracle. Probably Uniswap one|
|`baseRate`|`uint256`|The interest rate when utilization is 0|
|`slope1`|`uint256`|The interest rate slope when utilization is less than the targetUtilization|
|`slope2`|`uint256`|The interest rate slope when utilization is more than the targetUtilization|
|`targetUtilization`|`uint256`|The target utilization for the asset|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint16`|the index of the added ERC20 in the erc20Infos array|


### addERC721Info

Add a new ERC721 to be used inside Supa.

*For governance only.*


```solidity
function addERC721Info(address erc721Contract, address valueOracleAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721Contract`|`address`|The address of the ERC721 to be added|
|`valueOracleAddress`|`address`|The address of the Uniswap Oracle to get the price of a token|


### setConfig

Updates the config of Supa

*for governance only.*


```solidity
function setConfig(Config calldata _config) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_config`|`Config`|the Config of ISupaConfig. A struct with Supa parameters|


### setTokenStorageConfig

Updates the configuration setttings for credit account token storage

*for governance only.*


```solidity
function setTokenStorageConfig(TokenStorageConfig calldata _tokenStorageConfig) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenStorageConfig`|`TokenStorageConfig`|the TokenStorageconfig of ISupaConfig|


### setVersionManager

Set the address of Version Manager contract

*for governance only.*


```solidity
function setVersionManager(address _versionManager) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_versionManager`|`address`|The address of the Version Manager contract to be set|


### setERC20Data

Updates some of ERC20 config parameters

*for governance only.*


```solidity
function setERC20Data(
    address erc20,
    address valueOracle,
    uint256 baseRate,
    uint256 slope1,
    uint256 slope2,
    uint256 targetUtilization
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The address of ERC20 contract for which Supa config parameters should be updated|
|`valueOracle`|`address`|The address of the erc20 value oracle|
|`baseRate`|`uint256`|The interest rate when utilization is 0|
|`slope1`|`uint256`|The interest rate slope when utilization is less than the targetUtilization|
|`slope2`|`uint256`|The interest rate slope when utilization is more than the targetUtilization|
|`targetUtilization`|`uint256`|The target utilization for the asset|


### createWallet

creates a new wallet with sender as the owner and returns the wallet address


```solidity
function createWallet() external returns (address wallet);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the created wallet|


### pause

Pause the contract


```solidity
function pause() external;
```

### unpause

Unpause the contract


```solidity
function unpause() external;
```

### getCreditAccountERC20

Returns the amount of `erc20` tokens on creditAccount of wallet


```solidity
function getCreditAccountERC20(address walletAddr, IERC20 erc20) external view returns (int256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`walletAddr`|`address`|The address of the wallet for which creditAccount the amount of `erc20` should be calculated|
|`erc20`|`IERC20`|The address of ERC20 which balance on creditAccount of `wallet` should be calculated|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|the amount of `erc20` on the creditAccount of `wallet`|


### getCreditAccountERC721

returns the NFTs on creditAccount of `wallet`


```solidity
function getCreditAccountERC721(address wallet) external view returns (NFTData[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of wallet which creditAccount NFTs should be returned|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NFTData[]`|The array of NFT deposited on the creditAccount of `wallet`|


### getCreditAccountERC721Counter

returns the amount of NFTs in creditAccount of `wallet`


```solidity
function getCreditAccountERC721Counter(address wallet) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet that owns the creditAccount|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of NFTs in the creditAccount of `wallet`|


## Events
### WalletImplementationUpgraded
Emitted when the implementation of a wallet is upgraded


```solidity
event WalletImplementationUpgraded(address indexed wallet, string indexed version, address implementation);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|
|`version`|`string`|The new implementation version|
|`implementation`|`address`||

### WalletOwnershipTransferProposed
Emitted when the ownership of a wallet is proposed to be transferred


```solidity
event WalletOwnershipTransferProposed(address indexed wallet, address indexed newOwner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|
|`newOwner`|`address`|The address of the new owner|

### WalletOwnershipTransferred
Emitted when the ownership of a wallet is transferred


```solidity
event WalletOwnershipTransferred(address indexed wallet, address indexed newOwner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|
|`newOwner`|`address`|The address of the new owner|

### ERC20Added
Emitted when a new ERC20 is added to the protocol


```solidity
event ERC20Added(
    uint16 erc20Idx,
    address erc20,
    string name,
    string symbol,
    uint8 decimals,
    address valueOracle,
    uint256 baseRate,
    uint256 slope1,
    uint256 slope2,
    uint256 targetUtilization
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20Idx`|`uint16`|The index of the ERC20 in the protocol|
|`erc20`|`address`|The address of the ERC20 contract|
|`name`|`string`|The name of the ERC20|
|`symbol`|`string`|The symbol of the ERC20|
|`decimals`|`uint8`|The decimals of the ERC20|
|`valueOracle`|`address`|The address of the value oracle for the ERC20|
|`baseRate`|`uint256`|The interest rate at 0% utilization|
|`slope1`|`uint256`|The interest rate slope at 0% to target utilization|
|`slope2`|`uint256`|The interest rate slope at target utilization to 100% utilization|
|`targetUtilization`|`uint256`|The target utilization for the ERC20|

### ERC721Added
Emitted when a new ERC721 is added to the protocol


```solidity
event ERC721Added(uint256 indexed erc721Idx, address indexed erc721Contract, address valueOracleAddress);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc721Idx`|`uint256`|The index of the ERC721 in the protocol|
|`erc721Contract`|`address`|The address of the ERC721 contract|
|`valueOracleAddress`|`address`|The address of the value oracle for the ERC721|

### ConfigSet
Emitted when the config is set


```solidity
event ConfigSet(Config config);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`config`|`Config`|The new config|

### TokenStorageConfigSet
Emitted when the token storage config is set


```solidity
event TokenStorageConfigSet(TokenStorageConfig tokenStorageConfig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenStorageConfig`|`TokenStorageConfig`|The new token storage config|

### VersionManagerSet
Emitted when the version manager address is set


```solidity
event VersionManagerSet(address indexed versionManager);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`versionManager`|`address`|The version manager address|

### ERC20DataSet
Emitted when ERC20 Data is set


```solidity
event ERC20DataSet(
    address indexed erc20,
    uint16 indexed erc20Idx,
    address valueOracle,
    uint256 baseRate,
    uint256 slope1,
    uint256 slope2,
    uint256 targetUtilization
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`erc20`|`address`|The address of the erc20 token|
|`erc20Idx`|`uint16`|The index of the erc20 token|
|`valueOracle`|`address`|The new value oracle|
|`baseRate`|`uint256`|The new base interest rate|
|`slope1`|`uint256`|The new slope1|
|`slope2`|`uint256`|The new slope2|
|`targetUtilization`|`uint256`|The new target utilization|

### WalletCreated
Emitted when a wallet is created


```solidity
event WalletCreated(address wallet, address owner);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|
|`owner`|`address`|The address of the owner|

## Structs
### Config

```solidity
struct Config {
    address treasuryWallet;
    uint256 treasuryInterestFraction;
    uint256 maxSolvencyCheckGasCost;
    int256 liqFraction;
    int256 fractionalReserveLeverage;
}
```

### TokenStorageConfig

```solidity
struct TokenStorageConfig {
    uint256 maxTokenStorage;
    uint256 erc20Multiplier;
    uint256 erc721Multiplier;
}
```

### NFTData

```solidity
struct NFTData {
    address erc721;
    uint256 tokenId;
}
```

