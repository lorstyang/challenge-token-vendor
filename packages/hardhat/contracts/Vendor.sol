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

    }

    function sellTokens(uint256 amount) public {

    }
}
