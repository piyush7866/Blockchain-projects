// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// @dev : An interface IRandOracle is been defined which contains a function requestRandomNumber()
//@returns : It returns a uint256 integer

interface IRandOracle {
    function requestRandomNumber() external returns (uint256);
}