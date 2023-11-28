# GelatoBytes
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/gelato/GelatoBytes.sol)


## Functions
### calldataSliceSelector


```solidity
function calldataSliceSelector(bytes calldata _bytes) internal pure returns (bytes4 selector);
```

### memorySliceSelector


```solidity
function memorySliceSelector(bytes memory _bytes) internal pure returns (bytes4 selector);
```

### revertWithError


```solidity
function revertWithError(bytes memory _bytes, string memory _tracingInfo) internal pure;
```

### returnError


```solidity
function returnError(bytes memory _bytes, string memory _tracingInfo) internal pure returns (string memory);
```

