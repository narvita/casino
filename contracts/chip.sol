// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Chip is ERC20 {
    uint256 chest;
    uint256 public rate;
    address public owner;
    address casino;
    address chip = address(this);

    event Buy(address user, uint256 chipsCount, uint256 time);
    event Withdraw(address user, uint256 etherAmount, uint256 time);
    event Mint(address user, uint256 amount);
    event TransferFrom(address userr, address reciver, uint256 amount);
    event Burn( address user, uint256 amount);
    event Approve(address sender, address spender, uint256 amount);
     
    constructor(uint256 _rate) ERC20("Chip", "CHP") {
        owner = msg.sender;
        chest = 0;
        rate = _rate;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access restricted, not an owner");
        _;
    }

    function setRate(uint256 _rate) public onlyOwner() {
        rate = _rate;
    }
    
    function setCasino(address _casino) public onlyOwner() {
        casino = _casino;
    }
    
    function buyChips() public payable {
        require(msg.value > 0, "Message value should be more than 0");
        mint(msg.sender, msg.value * rate);
        emit Buy(msg.sender, msg.value * rate, block.timestamp);
    }

    function withdraw(uint256 chipsAmount) public {
        uint256 balance = balanceOf(msg.sender);
        uint256 ethAmount;
        require(chipsAmount <= balance, "isuffition balance");
        ethAmount = chipsAmount / rate * 80 / 100;
        chest += ethAmount / 4;
        payable(msg.sender).transfer(ethAmount);
        emit Withdraw(msg.sender, chipsAmount, block.timestamp);
        _burn(msg.sender, chipsAmount);
    }

    function mint(address account, uint256 amount) internal {
        _mint(account, amount);
        emit Mint(account, amount);
    }

    function returnAddress() public view returns (address) {
        return chip;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        emit Transfer(msg.sender, to, amount);
        approve(to, amount);
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(owner, spender, amount);
        emit Approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public  override returns (bool) {
        if (msg.sender == casino) {
            _approve(from, to, amount);
        }
        // super.transferFrom(from, to, amount);
        emit TransferFrom(from, to, amount);
        return true;
    }

   function burn(address account, uint256 amount) internal  {
        _burn(account, amount);
        emit Burn(account, amount);
    }
}