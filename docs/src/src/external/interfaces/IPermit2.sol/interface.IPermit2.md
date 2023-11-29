# IPermit2
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/external/interfaces/IPermit2.sol)


## Functions
### permitTransferFrom


```solidity
function permitTransferFrom(
    PermitTransferFrom calldata permit,
    SignatureTransferDetails calldata transferDetails,
    address owner,
    bytes calldata signature
) external;
```

## Structs
### TokenPermissions

```solidity
struct TokenPermissions {
    IERC20 token;
    uint256 amount;
}
```

### PermitTransferFrom

```solidity
struct PermitTransferFrom {
    TokenPermissions permitted;
    uint256 nonce;
    uint256 deadline;
}
```

### SignatureTransferDetails

```solidity
struct SignatureTransferDetails {
    address to;
    uint256 requestedAmount;
}
```

