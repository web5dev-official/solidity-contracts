// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/interfaces/IPancakeFactory.sol";
import "@pancakeswap/pancake-swap-lib/contracts/interfaces/IPancakePair.sol";
import "@pancakeswap/pancake-swap-lib/contracts/interfaces/IPancakeRouter02.sol";

contract ICOContract is Ownable {
    using SafeERC20 for IERC20;
    using SafeBEP20 for IBEP20;

    // The token being sold
    IERC20 public token;

    // The address where funds are collected
    address public wallet;

    // The price of each token in the ICO (tokens per BNB)
    uint256 public tokenPrice;

    // The total amount of tokens to be sold in the ICO
    uint256 public tokenAmount;

    // The amount of tokens already sold in the ICO
    uint256 public tokensSold;

    // The PancakeSwap router address
    IPancakeRouter02 public pancakeRouter;

    // The PancakeSwap pair for liquidity
    IPancakePair public pancakePair;

    // The address where liquidity tokens will be locked
    address public liquidityLock;

    // Flag indicating if the ICO has ended
    bool public ended;

    event ICOEnded(uint256 totalBNBRaised, uint256 totalTokensSold);

    constructor(
        IERC20 _token,
        address _wallet,
        uint256 _tokenPrice,
        uint256 _tokenAmount,
        IPancakeRouter02 _pancakeRouter,
        address _liquidityLock
    ) {
        token = _token;
        wallet = _wallet;
        tokenPrice = _tokenPrice;
        tokenAmount = _tokenAmount;
        pancakeRouter = _pancakeRouter;
        liquidityLock = _liquidityLock;

        // Create a PancakeSwap pair for the token
        pancakePair = IPancakeFactory(pancakeRouter.factory())
            .createPair(address(token), pancakeRouter.WETH());

        // Approve the PancakeSwap router to spend tokens
        token.approve(address(pancakeRouter), tokenAmount);
    }

    /**
     * @dev Buy tokens from the ICO by sending BNB.
     */
    function buyTokens() external payable {
        require(!ended, "ICO has ended");
        uint256 bnbAmount = msg.value;
        uint256 tokensToBuy = bnbAmount * tokenPrice;

        require(tokensToBuy <= (tokenAmount - tokensSold), "Not enough tokens left for sale");

        // Transfer tokens to the buyer
        token.safeTransfer(msg.sender, tokensToBuy);

        // Update the total tokens sold
        tokensSold += tokensToBuy;

        // Transfer BNB to the wallet
        (bool success, ) = wallet.call{value: bnbAmount}("");
        require(success, "Failed to send BNB to wallet");

        // If all tokens have been sold, end the ICO
        if (tokensSold == tokenAmount) {
            endICO();
        }
    }

    /**
     * @dev Ends the ICO and adds liquidity to PancakeSwap.
     */
    function endICO() private {
        require(!ended, "ICO has already ended");

        // Lock the liquidity tokens
        pancakePair.transfer(liquidityLock, pancakePair.balanceOf(address(this)));

        // Add liquidity to PancakeSwap
        uint256 tokenAmountForLiquidity = token.balanceOf(address(this));
        token.safeApprove(address(pancakeRouter), tokenAmountForLiquidity);
        pancakeRouter.addLiquidityETH{value: address(this).balance}(
            address(token),
            tokenAmountForLiquidity,
            0,
            0,
            address(this),
            block.timestamp
        );

        // End the ICO
        ended = true;

        emit ICOEnded(address(this).balance, tokensSold);
    }

    /**
     * @dev Allows the owner to withdraw unsold tokens.
     */
    function withdrawUnsoldTokens() external onlyOwner {
        require(ended, "ICO has not ended");

        uint256 unsoldTokenBalance = token.balanceOf(address(this));
        token.safeTransfer(owner(), unsoldTokenBalance);
    }

    /**
     * @dev Allows the owner to withdraw BNB from the contract.
     */
    function withdrawBNB() external onlyOwner {
        require(ended, "ICO has not ended");

        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Failed to withdraw BNB");
    }
}
