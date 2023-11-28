# SupaConfig
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/supa/SupaConfig.sol)

**Inherits:**
[SupaState](/src/supa/SupaState.sol/contract.SupaState.md), [ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md), [ISupaConfig](/src/interfaces/ISupa.sol/interface.ISupaConfig.md)


## Functions
### constructor


```solidity
constructor(address _owner) ImmutableGovernance(_owner);
```

### upgradeWalletImplementation

upgrades the version of walletLogic contract for the `wallet`


```solidity
function upgradeWalletImplementation(string calldata version) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`version`|`string`|The new target version of walletLogic contract|


### proposeTransferWalletOwnership

Proposes the ownership transfer of `wallet` to the `newOwner`

*The ownership transfer must be executed by the `newOwner` to complete the transfer*


```solidity
function proposeTransferWalletOwnership(address newOwner) external override onlyWallet whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`|The new owner of the `wallet`|


### executeTransferWalletOwnership

Executes the ownership transfer of `wallet` to the `newOwner`

*The caller must be the `newOwner` and the `newOwner` must be the proposed new owner*


```solidity
function executeTransferWalletOwnership(address wallet) external override whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the wallet|


### pause

Pause the contract


```solidity
function pause() external override onlyGovernance;
```

### unpause

Unpause the contract


```solidity
function unpause() external override onlyGovernance;
```

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
) external override onlyGovernance returns (uint16);
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
function addERC721Info(address erc721Contract, address valueOracleAddress) external override onlyGovernance;
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
function setConfig(Config calldata _config) external override onlyGovernance;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_config`|`Config`|the Config of ISupaConfig. A struct with Supa parameters|


### setTokenStorageConfig

Updates the configuration setttings for credit account token storage

*for governance only.*


```solidity
function setTokenStorageConfig(TokenStorageConfig calldata _tokenStorageConfig) external override onlyGovernance;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenStorageConfig`|`TokenStorageConfig`|the TokenStorageconfig of ISupaConfig|


### setVersionManager

Set the address of Version Manager contract

*for governance only.*


```solidity
function setVersionManager(address _versionManager) external override onlyGovernance;
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
) external override onlyGovernance;
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
function createWallet() external override whenNotPaused returns (address wallet);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|The address of the created wallet|


### getCreditAccountERC20

Returns the amount of `erc20` tokens on creditAccount of wallet


```solidity
function getCreditAccountERC20(address walletAddr, IERC20 erc20) external view override returns (int256);
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
function getCreditAccountERC721(address wallet) external view override returns (NFTData[] memory);
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


