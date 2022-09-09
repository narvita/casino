// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Chip  {
    uint256 public minVal;
    uint256 public maxVal;
    uint256 public Cap;
    uint256 public payments;
    uint256 public profit;
    address[] public blackList;
    address public owner;
    
    event fill(address user, uint256 chipsCount, uint256 time);
    event withdraw(address user, uint256 etherAmount, uint256 time);

    constructor(){
        owner = msg.sender;
        minVal = 1000000000000000000;
        maxVal = 3000000000000000000;
        Cap = 10000000000000000000;
        profit = 0;
        payments = 0;
    
    }  

    modifier onlyOwner() {
        require(msg.sender == owner, "Access restricted, not an owner");
        _;
    }

    function setMinTopUp(uint256  val) public onlyOwner() {
        require(val < maxVal, 'Val should not be max then ${maxVal}');
        minVal = val;
    }

    function setMaxTopUp(uint256  val) public onlyOwner() {
        require( val > minVal);
        maxVal = val;
    }

    function setCap(uint256 val) public onlyOwner() {
        Cap = val;
    }

    modifier isUserAllowed(address sender) {
        for(uint256 i = 0; i < blackList.length; i++) {
                require(blackList[i] != sender, "User already participated");
        }
        blackList.push(sender);
        _;
    }

     function clearAddresList() private {
        delete blackList;
    }


    function topUp() public payable isUserAllowed(msg.sender) {
        require(msg.value > minVal && msg.value < maxVal, "Value is note within allowed boundaries");
        payments += msg.value;
        if( payments >= Cap) {
            address payable to = payable(msg.sender);
            to.transfer((payments/100)*80);
            profit += (payments/100)*20;
            payments = 0;
            clearAddresList();
        }
            emit fill(msg.sender, (payments/100)*80, block.timestamp);
    }

    function withdrawAll() public onlyOwner {
        address payable Owner = payable(owner);
        Owner.transfer(profit);
        emit withdraw(Owner, profit, block.timestamp);
        profit = 0;
    }
}