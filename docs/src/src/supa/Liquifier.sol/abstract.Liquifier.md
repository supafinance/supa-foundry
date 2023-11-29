# Liquifier
[Git Source](https://github.com/supafinance/supa-foundry/blob/00eb35447ebc05e824f31afa1581898206764621/src/supa/Liquifier.sol)

**Inherits:**
[WalletState](/src/wallet/WalletState.sol/abstract.WalletState.md)

*It is designed to be an extension for walletLogic contract.
Functionally, it's a part of the walletLogic contract, but has been extracted into a separate
contract for better code structuring. This is why the contract is declared as abstract
The only function it exports is `liquify`. The rest are private function that are parts of
`liquify`*


## Functions
### selfOrWalletOwner


```solidity
modifier selfOrWalletOwner();
```

### liquify

Advanced version of liquidate function. Potentially unwanted side-affect of
liquidation is a debt on the liquidator. So liquify would liquidate and then re-balance
obtained assets to have no debt. This is the algorithm:
* liquidate creditAccount of target `wallet`
* terminate all obtained ERC721s (NFTs)
* buy/sell `erc20s` for `numeraire` so the balance of `wallet` on that ERC20s matches the
debt of `wallet` on it's creditAccount. E.g.:
- for 1 WETH of debt on creditAccount and 3 WETH on the balance of wallet - sell 2 WETH
- for 3 WETH of debt on creditAccount and 1 WETH on the balance of wallet - buy 2 WETH
- for no debt on creditAccount and 1 WETH on the balance of wallet - sell 2 WETH
- for 1 WETH of debt on creditAccount and no WETH on the balance of dSave - buy 1 WETH
* deposit `erc20s` and `numeraire` to cover debts
!! IMPORTANT: because this function executes quite a lot of logic on top of Supa.liquidate(),
there is a risk that for liquidatable position with a long list of NFTs it will run out
of gas. As for now, it's up to liquidator to estimate if specific position is liquifiable,
or Supa.liquidate() need to be used (with further assets re-balancing in other transactions)

*notes on erc20s: the reason for erc20s been a call parameter, and not been calculated
inside of liquify, is reducing gas costs
erc20s should NOT include numeraire. Otherwise, the transaction would be reverted with an
error from uniswap router
It's the responsibility of caller to provide the correct list of erc20s. Assets
re-balancing would be performed only by this list of tokens and numeraire.
* if erc20s misses a token that liquidatable have debt on - the debt on this erc20 would
persist on liquidator's creditAccount as-is
* if erc20s misses a token that liquidatable have collateral on - the token would persist
on liquidator's creditAccount. It may result in generating debt in numeraire on liquidator
creditAccount by the end of liquify (because the token would not be soled for numeraire,
there may not be enough numeraire to buy tokens to cover debts, and so they will be
bought in debt)
* if erc20s misses a token that would be obtained as the result of NFT termination - same
as previous, except of the token to be persisted on wallet instead of creditAccount of
liquidator
Because no buy/sell would be done for prices from outside of the erc20sAllowedPriceRanges,
too narrow range may result in not having enough of some ERC20 to cover the debt. So the
eventual state would still include some debt*


```solidity
function liquify(
    address wallet,
    address swapRouter,
    address nftManager,
    address numeraire,
    IERC20[] calldata erc20s,
    SqrtPricePriceRangeX96[] calldata erc20sAllowedPriceRanges
) external selfOrWalletOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`wallet`|`address`|- the address of a wallet to liquidate|
|`swapRouter`|`address`|- the address of a Uniswap swap router to be used to buy/sell erc20s|
|`nftManager`|`address`|- the address of a Uniswap NonFungibleTokenManager to be used to terminate ERC721 (NFTs)|
|`numeraire`|`address`|- the address of an ERC20 to be used to convert to and from erc20s. The liquidation reward would be in this token|
|`erc20s`|`IERC20[]`|- the list of ERC20 that liquidated has debt, collateral or that would be obtained from termination of any ERC721 that he owns. Except of numeraire, that should never be included in erc20s array|
|`erc20sAllowedPriceRanges`|`SqrtPricePriceRangeX96[]`|- the list of root squares of allowed prices in Q96 for `erc20s` swaps on Uniswap in `numeraire`. This is the protection against sandwich-attack - if the price would be lower/higher for sell/buy It's up to liquidator to decide what range is acceptable. +/- 1% of price before liquify call seems to be reasonable Zero minSell/maxBuy value for a specific ERC20 would disable the corresponding check Uniswap docs - https://docs.uniswap.org/contracts/v3/guides/swaps/single-swaps It doesn't explained in Uniswap docs, but this is how it actually works: * if the price for each token would be below the specified limit then full amount would be converted and no error would be thrown * if at least some amount of tokens can be bought by the price that is below the limit then only that amount of tokens would be bought and no error would be thrown * if no tokens can be bought by the price below the limit then error would be thrown with message "SPL"|


### callOverBatchExecute


```solidity
function callOverBatchExecute(
    address wallet,
    address swapRouter,
    address nftManager,
    address numeraire,
    IERC20[] calldata erc20s,
    SqrtPricePriceRangeX96[] calldata erc20sAllowedPriceRanges
) private;
```

### terminateERC721s


```solidity
function terminateERC721s(address nftManager) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nftManager`|`address`|- passed as-is from liquify function. The address of a Uniswap NonFungibleTokenManager to be used to terminate ERC721 (NFTs)|


### analyseCreditAccountStructure


```solidity
function analyseCreditAccountStructure(IERC20[] calldata erc20s, address numeraire)
    private
    view
    returns (IERC20[] memory erc20sCollateral, uint256[] memory erc20sDebtAmounts);
```

### calcSellAndBuyERC20Amounts


```solidity
function calcSellAndBuyERC20Amounts(IERC20[] calldata erc20s, uint256[] memory erc20sDebtAmounts)
    private
    view
    returns (uint256[] memory erc20ToSellAmounts, uint256[] memory erc20ToBuyAmounts);
```

### sellERC20s


```solidity
function sellERC20s(
    address swapRouter,
    IERC20[] memory erc20sToSell,
    uint256[] memory amountsToSell,
    address erc20ToSellFor,
    SqrtPricePriceRangeX96[] calldata erc20sAllowedPriceRanges
) private;
```

### buyERC20s


```solidity
function buyERC20s(
    address swapRouter,
    IERC20[] memory erc20sToBuy,
    uint256[] memory amountsToBuy,
    address erc20ToBuyFor,
    SqrtPricePriceRangeX96[] calldata erc20sAllowedPriceRanges
) private;
```

### deposit


```solidity
function deposit(IERC20[] memory erc20s, address numeraire) private;
```

## Errors
### OnlySelfOrOwner
Only this address or the Wallet owner can call this function


```solidity
error OnlySelfOrOwner();
```

