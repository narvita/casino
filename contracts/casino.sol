// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Casino {
    uint256 public minVal;
    uint256 public maxVal;
    uint256 public Cap;
    uint256 public payments;
    uint256 public profit;
    address[] public blackList;
    address public owner;

    constructor() {
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
    }

    function withdrawAll() public onlyOwner {
        address payable Owner = payable(owner);
        Owner.transfer(profit);
        profit = 0;
    }
}