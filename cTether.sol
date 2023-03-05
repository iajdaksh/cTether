// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract cTether is ERC20 {
    AggregatorV3Interface internal priceFeed;
    address public collateral;
    uint256 public collateralRatio;
    uint256 public transactionFee;
    address public feeAddress;
    
    constructor(string memory _name, string memory _symbol, address _collateral, uint256 _collateralRatio, address _priceFeed, uint256 _transactionFee, address _feeAddress)
        ERC20(_name, _symbol)
    {
        collateral = _collateral;
        collateralRatio = _collateralRatio;
        priceFeed = AggregatorV3Interface(_priceFeed);
        transactionFee = _transactionFee;
        feeAddress = _feeAddress;
    }
    
    function mint(uint256 amount) public {
        uint256 collateralAmount = amount * getPrice() / collateralRatio;
        IERC20(collateral).transferFrom(msg.sender, address(this), collateralAmount);
        _mint(msg.sender, amount);
    }
    
    function burn(uint256 amount) public {
        uint256 collateralAmount = amount * getPrice() / collateralRatio;
        _burn(msg.sender, amount);
        IERC20(collateral).transfer(msg.sender, collateralAmount);
    }
    
    function getPrice() public view returns (uint256) {
        (, int256 price, , ,) = priceFeed.latestRoundData();
        require(price > 0, "invalid price");
        return uint256(price);
    }
}
