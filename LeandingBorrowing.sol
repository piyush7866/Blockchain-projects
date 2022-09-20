// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./NeoToken.sol";
contract LeandingBorrowing is NeoToken {
    mapping(address => uint256) balance;
    address public contractOwner;
    uint256 public intialSupply;

    constructor() NeoToken(intialSupply) {
        contractOwner = msg.sender;
    }

    function Leanding() public payable {
        require(msg.value > 1 ether);
        uint256 tokenAmount = msg.value/10**15;
        _mint(msg.sender, tokenAmount);
    }

    function borrowing(uint256 _tokens) public {
        require(balanceOf(msg.sender) >= _tokens);
        transfer(address(this), _tokens);
        uint etherAmount = _tokens *10**15;
        transferFrom(address(this), payable(msg.sender), etherAmount);

    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}