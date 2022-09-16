// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChipInterface {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external view returns (bool);
    function returnAddress() external view returns (address);

}