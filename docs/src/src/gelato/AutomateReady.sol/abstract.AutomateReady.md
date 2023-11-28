# AutomateReady
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/AutomateReady.sol)

*Inherit this contract to allow your smart contract to
- Make synchronous fee payments.
- Have call restrictions for functions to be automated.*


## State Variables
### automate

```solidity
IAutomate public immutable automate;
```


### dedicatedMsgSender

```solidity
address public immutable dedicatedMsgSender;
```


### feeCollector

```solidity
address private immutable feeCollector;
```


### ETH

```solidity
address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
```


## Functions
### onlyDedicatedMsgSender

*
Only tasks created by _taskCreator defined in constructor can call
the functions with this modifier.*


```solidity
modifier onlyDedicatedMsgSender();
```

### constructor

*
_taskCreator is the address which will create tasks for this contract.*


```solidity
constructor(address _automate, address _taskCreator);
```

### _transfer

*
Transfers fee to gelato for synchronous fee payments.
_fee & _feeToken should be queried from IAutomate.getFeeDetails()*


```solidity
function _transfer(uint256 _fee, address _feeToken) internal;
```

### _getFeeDetails


```solidity
function _getFeeDetails() internal view returns (uint256 fee, address feeToken);
```

