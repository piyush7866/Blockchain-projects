// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// @dev : An interface ICaller is defined which contains function fullfillRandomNumberRequest()
// @params : The function contains two arguments randomNumber , id of type uint256.

interface ICaller {
    function fulfillRandomNumberRequest(uint256 randomNumber, uint256 id) external;
}