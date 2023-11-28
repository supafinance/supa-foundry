# TaskCreator
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/TaskCreator.sol)

**Inherits:**
[ITaskCreator](/src/gelato/interfaces/ITaskCreator.sol/interface.ITaskCreator.md), [AutomateTaskCreator](/src/gelato/AutomateTaskCreator.sol/abstract.AutomateTaskCreator.md), Ownable, ERC20


## State Variables
### implementation
*This makes sure we don't override the implementation address on the proxy*


```solidity
address public implementation = address(this);
```


### feeCollector
The address of the fee collector


```solidity
address public feeCollector;
```


### tiers
The tiers for power purchase


```solidity
Tier[] public tiers;
```


### supa
The supa address


```solidity
SupaState public immutable supa;
```


### usdc
The USDC address


```solidity
IERC20 public immutable usdc;
```


### depositAmount
The deposit amount for task creation


```solidity
uint256 public depositAmount;
```


### powerPerExecution
The power credits per execution


```solidity
uint256 public powerPerExecution;
```


### taskOwner
Mapping of task owners


```solidity
mapping(bytes32 taskId => address taskOwner) public taskOwner;
```


### depositAmounts
Mapping of task deposit amounts


```solidity
mapping(bytes32 taskId => uint256 depositAmount) public depositAmounts;
```


### taskExecFrequency
Mapping of task execution frequencies


```solidity
mapping(bytes32 taskId => uint256 taskExecFrequency) public taskExecFrequency;
```


### userPowerData
Mapping of user's power data (power credits, lastUpdate, taskExecsPerSecond)


```solidity
mapping(address user => UserPowerData userPowerData) public userPowerData;
```


### allowlistRole

```solidity
mapping(address admin => bool isAllowed) public allowlistRole;
```


### allowlistCid

```solidity
mapping(string cid => bool isAllowed) public allowlistCid;
```


### gasPriceFeed

```solidity
AggregatorV3Interface public gasPriceFeed;
```


## Functions
### onlyTaskOwner

Reverts if called by any account that is not the task owner or the task owner's wallet owner


```solidity
modifier onlyTaskOwner(bytes32 taskId);
```

### onlySupaWallet

Reverts if called by any account that is not a supa wallet


```solidity
modifier onlySupaWallet();
```

### onlyAllowlistRole


```solidity
modifier onlyAllowlistRole();
```

### constructor


```solidity
constructor(address _supa, address _automate, address _taskCreatorProxy, address _usdc)
    AutomateTaskCreator(_automate, _taskCreatorProxy)
    ERC20("Supa Power Credits", "PWR");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_supa`|`address`|The address of the supa contract|
|`_automate`|`address`|The address of the automate contract|
|`_taskCreatorProxy`|`address`|The address of the task creator proxy|
|`_usdc`|`address`||


### purchasePowerExactUsdc

Purchase power credits

*The amount of power credits purchased is calculated based on the amount of USDC sent*


```solidity
function purchasePowerExactUsdc(address user, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user to purchase power for|
|`amount`|`uint256`|The amount of USDC to send|


### purchasePowerCredits

Purchase power credits

*The amount of USDC required is calculated based on the amount of power credits requested*


```solidity
function purchasePowerCredits(address user, uint256 powerCreditsToPurchase) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user to purchase power for|
|`powerCreditsToPurchase`|`uint256`|The amount of power credits to purchase|


### adminIncreasePower

Admin function to increase a user's power credits

*Can only be called by an allowlisted role*


```solidity
function adminIncreasePower(address user, uint256 creditAmount) external onlyAllowlistRole;
```

### cancelTask

Cancels the task with id `taskId`

*Can only be called by the task owner*


```solidity
function cancelTask(bytes32 taskId) external onlyTaskOwner(taskId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`taskId`|`bytes32`|The id of the task to cancel|


### cancelInsolventTask

Cancels the task with id `taskId` if the task is insolvent

*revert if the task is solvent*


```solidity
function cancelInsolventTask(bytes32 taskId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`taskId`|`bytes32`|The id of the task to cancel|


### createTask

Create an automation task


```solidity
function createTask(
    uint256 automationId,
    address operatorAddress,
    string memory cid,
    uint256 interval,
    bool payGasWithCredits
) external onlySupaWallet returns (bytes32 taskId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`automationId`|`uint256`|The id of the automation to execute|
|`operatorAddress`|`address`|The address of the operator|
|`cid`|`string`|The cid of the W3f to execute|
|`interval`|`uint256`|The interval at which to execute the task|
|`payGasWithCredits`|`bool`|Whether to pay gas with credits|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`taskId`|`bytes32`|The id of the created task|


### createTask

Create an automation task


```solidity
function createTask(
    uint256 automationId,
    address operatorAddress,
    string memory cid,
    uint256 interval,
    bool payGasWithCredits,
    address admin,
    bytes calldata signature
) external onlySupaWallet returns (bytes32 taskId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`automationId`|`uint256`|The id of the automation|
|`operatorAddress`|`address`|The address of the operator|
|`cid`|`string`|The cid of the W3f to execute|
|`interval`|`uint256`|The interval at which to execute the task|
|`payGasWithCredits`|`bool`|Whether to pay gas with credits|
|`admin`|`address`|The address of the signer|
|`signature`|`bytes`|The signature of the cid|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`taskId`|`bytes32`|The id of the created task|


### payGas

Pay for gas with power credits

*The amount of power credits used is calculated based on the amount of gas used*


```solidity
function payGas(uint256 gasAmount) external onlySupaWallet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gasAmount`|`uint256`|The amount of gas used|


### payGasNative

Pay for gas with power credits

*The amount of power credits used is calculated based on the amount of gas used*


```solidity
function payGasNative(uint256 gasAmount) external payable onlySupaWallet;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`gasAmount`|`uint256`|The amount of gas used|


### _transferEth


```solidity
function _transferEth(address to, uint256 amount) internal;
```

### depositFunds1Balance

Fund executions by depositing to 1Balance


```solidity
function depositFunds1Balance(address token, uint256 amount) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token to deposit|
|`amount`|`uint256`|The amount to deposit|


### setTiers

Set the tiers for power purchase


```solidity
function setTiers(Tier[] memory newTiers) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newTiers`|`Tier[]`|The new tiers|


### setFeeCollector


```solidity
function setFeeCollector(address _feeCollector) external onlyOwner;
```

### setDepositAmount

Set the deposit amount for task creation


```solidity
function setDepositAmount(uint256 _depositAmount) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_depositAmount`|`uint256`|The new deposit amount|


### setPowerPerExecution

Set the power credits per execution


```solidity
function setPowerPerExecution(uint256 _powerPerExecution) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_powerPerExecution`|`uint256`|The new power credits per execution|


### setGasPriceFeed


```solidity
function setGasPriceFeed(address priceFeed) external onlyOwner;
```

### addAllowlistRole


```solidity
function addAllowlistRole(address role) external onlyOwner;
```

### removeAllowlistRole


```solidity
function removeAllowlistRole(address role) external onlyOwner;
```

### addAllowlistCid


```solidity
function addAllowlistCid(string memory cid) external onlyAllowlistRole;
```

### removeAllowlistCid


```solidity
function removeAllowlistCid(string memory cid) external onlyAllowlistRole;
```

### balanceOf

Get the current power credits for `user`


```solidity
function balanceOf(address user) public view override returns (uint256 remainingPowerCredits);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user to get the power credits for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`remainingPowerCredits`|`uint256`|The remaining power credits for `user`|


### getUserDailyBurn

Get the daily power burn for `user`


```solidity
function getUserDailyBurn(address user) external view returns (uint256 dailyBurn);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The user to get the daily power burn for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dailyBurn`|`uint256`|The daily power burn for `user`|


### calculateUsdcForPower

Calculate the USDC required to purchase `powerAmount` power credits


```solidity
function calculateUsdcForPower(uint256 powerAmount) public view returns (uint256 usdcRequired);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`powerAmount`|`uint256`|The amount of power credits to purchase|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`usdcRequired`|`uint256`|The amount of USDC required to purchase `powerAmount` power credits|


### calculatePowerPurchase


```solidity
function calculatePowerPurchase(uint256 usdcAmount) public view returns (uint256 powerToPurchase);
```

### getAllTiers

Get all power credit usdc tiers


```solidity
function getAllTiers() public view returns (Tier[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Tier[]`|tiers The tiers|


### _burnUsedCredits


```solidity
function _burnUsedCredits(address _taskOwner, bytes32 _taskId) internal returns (bool insolvent);
```

### _onlyTaskOwner


```solidity
function _onlyTaskOwner(bytes32 taskId) internal view;
```

