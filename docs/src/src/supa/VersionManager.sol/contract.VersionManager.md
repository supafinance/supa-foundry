# VersionManager
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/supa/VersionManager.sol)

**Inherits:**
[IVersionManager](/src/interfaces/IVersionManager.sol/interface.IVersionManager.md), [ImmutableGovernance](/src/lib/ImmutableGovernance.sol/contract.ImmutableGovernance.md)


## State Variables
### _versionString
*Array of all version names*


```solidity
string[] internal _versionString;
```


### _versions
*Mapping from version names to version structs*


```solidity
mapping(string => Version) internal _versions;
```


### _recommendedVersion
*The recommended version*


```solidity
string internal _recommendedVersion;
```


## Functions
### versionExists


```solidity
modifier versionExists(string memory versionName);
```

### validStatus


```solidity
modifier validStatus(Status status);
```

### validBugLevel


```solidity
modifier validBugLevel(BugLevel bugLevel);
```

### constructor


```solidity
constructor(address _owner) ImmutableGovernance(_owner);
```

### addVersion

Registers a new version of the store contract


```solidity
function addVersion(Status status, address _implementation) external onlyGovernance validStatus(status);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`status`|`Status`|Status of the version to be added|
|`_implementation`|`address`|The address of the implementation of the version|


### updateVersion

Update a contract version


```solidity
function updateVersion(string calldata versionName, Status status, BugLevel bugLevel)
    external
    onlyGovernance
    versionExists(versionName)
    validStatus(status)
    validBugLevel(bugLevel);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`versionName`|`string`|Version of the contract|
|`status`|`Status`|Status of the contract|
|`bugLevel`|`BugLevel`|New bug level for the contract|


### markRecommendedVersion

Set the recommended version


```solidity
function markRecommendedVersion(string calldata versionName) external onlyGovernance versionExists(versionName);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`versionName`|`string`|Version of the contract|


### removeRecommendedVersion

Remove the recommended version


```solidity
function removeRecommendedVersion() external onlyGovernance;
```

### getRecommendedVersion

Get recommended version for the contract.


```solidity
function getRecommendedVersion()
    external
    view
    returns (string memory versionName, Status status, BugLevel bugLevel, address implementation, uint256 dateAdded);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`versionName`|`string`|The name of the recommended version|
|`status`|`Status`|The status of the recommended version|
|`bugLevel`|`BugLevel`|The bug level of the recommended version|
|`implementation`|`address`|The address of the implementation of the recommended version|
|`dateAdded`|`uint256`|The date the recommended version was added|


### getVersionCount

Get total count of versions


```solidity
function getVersionCount() external view returns (uint256 count);
```

### getVersionAtIndex

*Returns the version name at specific index in the versionString[] array*


```solidity
function getVersionAtIndex(uint256 index) external view returns (string memory versionName);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index to be searched for|


### getVersionAddress

Get the implementation address for a version


```solidity
function getVersionAddress(uint256 index) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index of the version|


### getVersionDetails

Returns the version details for the given version name


```solidity
function getVersionDetails(string calldata versionName)
    external
    view
    returns (string memory versionString, Status status, BugLevel bugLevel, address implementation, uint256 dateAdded);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`versionName`|`string`|Version string|


