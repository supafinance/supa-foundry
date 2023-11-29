# IVersionManager
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/interfaces/IVersionManager.sol)


## Functions
### addVersion

Registers a new version of the store contract


```solidity
function addVersion(Status status, address _implementation) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`status`|`Status`|Status of the version to be added|
|`_implementation`|`address`|The address of the implementation of the version|


### updateVersion

Update a contract version


```solidity
function updateVersion(string calldata versionName, Status status, BugLevel bugLevel) external;
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
function markRecommendedVersion(string calldata versionName) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`versionName`|`string`|Version of the contract|


### removeRecommendedVersion

Remove the recommended version


```solidity
function removeRecommendedVersion() external;
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


## Events
### VersionAdded

```solidity
event VersionAdded(string versionName, address indexed implementation);
```

### VersionUpdated

```solidity
event VersionUpdated(string versionName, Status status, BugLevel bugLevel);
```

### VersionRecommended

```solidity
event VersionRecommended(string versionName);
```

### RecommendedVersionRemoved

```solidity
event RecommendedVersionRemoved();
```

## Structs
### Version
*A struct to encode version details*


```solidity
struct Version {
    string versionName;
    Status status;
    BugLevel bugLevel;
    address implementation;
    uint256 dateAdded;
}
```

## Enums
### Status
*Signifies the status of a version*


```solidity
enum Status {
    BETA,
    RC,
    PRODUCTION,
    DEPRECATED
}
```

### BugLevel
*Indicated the highest level of bug found in the version*


```solidity
enum BugLevel {
    NONE,
    LOW,
    MEDIUM,
    HIGH,
    CRITICAL
}
```

