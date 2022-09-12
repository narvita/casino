// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Chip is ERC20{
    uint256 chest;
    uint256 public rate;
    address public owner;
    address casino;
    uint public _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

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
        _balances[msg.sender] = _totalSupply;
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

    function _mint(address account, uint256 amount) internal virtual override {
        emit Mint(account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    
    function totalSupply() public view override  returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        emit Transfer(msg.sender, to, amount);
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address  _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[ _owner][spender];
    }
   
    function approve(address spender, uint256 amount) public override virtual returns (bool) {
        address _owner = _msgSender();
        emit Approve(msg.sender, spender, amount);
        _approve(_owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        emit TransferFrom(from, to, amount);
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function burn(address account, uint256 id) public virtual {
        emit Burn(account, id);
        _burn(owner, id);
    }
}