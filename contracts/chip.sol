// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Chip is ERC20{
    uint256 chest;
    uint256 public rate;
    address public owner;
    address casino;

    event Buy(address user, uint256 chipsCount, uint256 time);
    event withdraw(address user, uint256 etherAmount, uint256 time);

    constructor(uint256 _rate) ERC20("Chip", "CHP") {
        owner = msg.sender;
        chest = 0;
        rate = _rate;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access restricted, not an owner");
        _;
    }

     function setRate(uint256 val) public onlyOwner() {
        rate = val;
    }

    function buyChips() public payable {
        require(msg.value > 0, "Message value should be more than 0");
         _mint(msg.sender, msg.value * rate);
         emit Buy(msg.sender, msg.value * rate, block.timestamp);
    }

   function withdrawAll(uint256 chipsAmount) public {
        uint256 balance = balanceOf(msg.sender);
        uint256 ethAmount;
        require(chipsAmount < balance, "suffition balance");
        ethAmount = chipsAmount / rate * 80 / 100;
        chest += ethAmount / 4;
        payable(msg.sender).transfer(ethAmount);
        emit withdraw(msg.sender, chipsAmount, block.timestamp);
        _burn(msg.sender, chipsAmount);
    }
}