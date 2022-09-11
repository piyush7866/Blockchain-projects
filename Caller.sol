// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./IRandOracle.sol";

contract Caller is Ownable {
    IRandOracle private randOracle;
    /* 
    @dev : mapping request is used to keep track of active request ID.
    and mapping results is used to store the random number received for each request ID.
    */
    mapping(uint256 => bool) requests;
    mapping (uint256 => uint256) results;

        /* 
        @dev : modifier onlyRandOracle is used to restrict the access and it checks if the function caller
        address is that of oracle contract and if not it will throw error. Without this modifier any random 
        user will be able to submit its random number request.
        */
        modifier onlyRandOracle() {
        require(msg.sender == address(randOracle), "Unauthorized.");
        _;
    }


    /* 
    @dev : Owner will be able to change the oracle address
    @params : The function will take an address type parameter newAddress.
    @event :  Emits the event OracleAddressChanged so that caller would know that the address of oracle has changed.
    */
    function setRandOracleAddress(address newAddress) external onlyOwner {
        randOracle = IRandOracle(newAddress);

        emit OracleAddressChanged(newAddress);
    }

    /* 
    @dev : Here in this function getRandomNumber() we use a require statement to ensure that the contract's 
    oracle is initialized. 
    We do this by checking that it is not a contract at the null address, 
    which is the address of uninitialized contract references. 
    We then call requestRandomNumber(), the function that we declared in the IRandOracle interface. 
    This function will return a request ID, which we mark as valid in our requests mapping. 

    @event: we emit an event to show that a random number has been requested.
    
    */

    function getRandomNumber() external {
        require(randOracle != IRandOracle(address(0)), "Oracle not initialized.");

        uint256 id = randOracle.requestRandomNumber();
        requests[id] = true;

        emit RandomNumberRequested(id);
    }

    /* 
    @dev : This function will fullfill the random number request , first by checking if it is a valid request number or not
    then then that random number is saved in the results mapping crossponding to the request id .
    Now that the request has been fulfilled, it will also delete the request ID from requests, 
    which is equivalent to setting it to false. 
    This will ensure that only active requests are tracked.

    @params : uint256 type randomNumber and id parameters is used

    @event: Then emit event RandomNumberRecevied to give signal that random number is received.
    */

        function fulfillRandomNumberRequest(uint256 randomNumber, uint256 id) external onlyRandOracle {
        require(requests[id], "Request is invalid or already fulfilled.");

        results[id] = randomNumber;
        delete requests[id];

        emit RandomNumberReceived(randomNumber, id);
    }

    event OracleAddressChanged(address oracleAddress);
    event RandomNumberRequested(uint256 id);
    event RandomNumberReceived(uint256 number, uint256 id);
}
