// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Chip is ERC20{
    uint256 chest;
    uint256 public rate;
    address public owner;
    address casino;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 totalSupply_ = 10 ether;

    event Buy(address user, uint256 chipsCount, uint256 time);
    event Withdraw(address user, uint256 etherAmount, uint256 time);
    event Allowance(address user, address delegate);


    constructor(uint256 _rate) ERC20("Chip", "CHP") {
        owner = msg.sender;
        chest = 0;
        rate = _rate;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);        
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address delegate) public override view returns (uint) {
        return allowed[_owner][delegate];
    }

    function transferFrom(address _owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[_owner]);
        require(numTokens <= allowed[_owner][msg.sender]);
        balances[_owner] = balances[_owner]-numTokens;
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(_owner, buyer, numTokens);
        return true;
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
        emit Withdraw(msg.sender, chipsAmount, block.timestamp);
        _burn(msg.sender, chipsAmount);
    }
}