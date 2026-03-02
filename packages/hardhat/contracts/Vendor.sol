pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    /////////////////
    /// Errors //////
    /////////////////
 
    error InvalidEthAmount();
    error InsufficientVendorTokenBalance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);
    error InvalidTokenAmount();
    error InsufficientVendorEthBalance(uint256 available, uint256 required);
    event SellTokens(address indexed seller, uint256 amountOfTokens, uint256 amountOfETH);

    //////////////////////
    /// State Variables //
    //////////////////////

    YourToken public immutable yourToken;
    uint256 public constant tokensPerEth = 100;

    ////////////////
    /// Events /////
    ////////////////

    event BuyTokens(address indexed buyer, uint256 amountOfETH, uint256 amountOfTokens);

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function buyTokens() external payable {
        if (0 == msg.value) revert InvalidEthAmount();

        uint256 amountBuy = msg.value * tokensPerEth;
        uint256 vendorBalance = yourToken.balanceOf(address(this));
        if (vendorBalance < amountBuy)
            revert InsufficientVendorTokenBalance({
                available: vendorBalance,
                required: amountBuy
            });
        yourToken.transfer(msg.sender, amountBuy);
        emit BuyTokens(msg.sender, msg.value, amountBuy);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = owner().call{value: amount}("");
        if (!success) revert EthTransferFailed(owner(), amount);
    }

    function sellTokens(uint256 amount) public {
        if (0 == amount) revert InvalidTokenAmount();
        uint256 amountEth = amount / tokensPerEth;
        uint256 vendorEthBalance = address(this).balance;
        if (vendorEthBalance < amountEth) revert InsufficientVendorEthBalance({
            available: vendorEthBalance,
            required: amountEth
        });
        yourToken.transferFrom(msg.sender, address(this), amount);
        (bool success, ) = msg.sender.call{value: amountEth}("");
        if (!success) revert EthTransferFailed(msg.sender, amountEth);
        emit SellTokens(msg.sender, amount, amountEth);
    }
}
