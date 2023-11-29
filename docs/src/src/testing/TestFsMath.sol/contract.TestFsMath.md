# TestFsMath
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/testing/TestFsMath.sol)


## Functions
### abs


```solidity
function abs(int256 value) external pure returns (uint256);
```

### sabs


```solidity
function sabs(int256 value) external pure returns (int256);
```

### sign


```solidity
function sign(int256 value) external pure returns (int256);
```

### min


```solidity
function min(int256 a, int256 b) external pure returns (int256);
```

### max


```solidity
function max(int256 a, int256 b) external pure returns (int256);
```

### clip


```solidity
function clip(int256 val, int256 lower, int256 upper) external pure returns (int256);
```

### safeCastToSigned


```solidity
function safeCastToSigned(uint256 x) external pure returns (int256);
```

### safeCastToUnsigned


```solidity
function safeCastToUnsigned(int256 x) external pure returns (uint256);
```

### exp


```solidity
function exp(int256 x) external pure returns (int256);
```

### sqrt


```solidity
function sqrt(int256 x) external pure returns (int256);
```

### bitCount


```solidity
function bitCount(uint256 x) external pure returns (uint256);
```

