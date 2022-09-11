// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/* 
@title : An oracle smart contract for getting random number data using off-chain interaction.
@author : Piyush Raj
@dev : The contract is authorized to request a random number and then it will fullfill that request.
@notice: The program will give a random number as requested by the user.

*/


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import "./ICaller.sol";

contract RandOracle is AccessControl {

        //  we define a name for our data provider role, in accordance with the AccessControl contract's documentation.
        bytes32 public constant PROVIDER_ROLE = keccak256("PROVIDER_ROLE");

        // numProviders to store the total count of data providers we've added to the contract
        uint private numProviders = 0;

        //providersThreshold to define the minimum number of provider responses we need to consider a request fulfilled.
        uint private providersThreshold = 1;

        // a cryptographic nonce we'll use to generate request IDs. 
        //This will be a simple counter that we increment every time requestRandomNumber() is called.
        uint private randNonce = 0;

        // pendingRequests, a mapping of requests awaiting fulfillment, similar to requests in our Caller contract.
        mapping(uint256=>bool) private pendingRequests;
    
        // The Response struct, in which we'll store all the key details of each random number we receive from data providers: 
        //who requested the number, who provided the number, and the number itself.
    struct Response {
        address providerAddress;
        address callerAddress;
        uint256 randomNumber;
    }

    // idToResponses, a mapping of request IDs to arrays of Response structs. This will allow us to track responses per request.
    mapping(uint256=>Response[]) private idToResponses;

        //This constructor assigns AccessControl's DEFAULT_ADMIN_ROLE to the contract's deploying address, commonly called its owner. 
        //This role has the power to grant and revoke other roles.
        constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // make the deployer admin
    }

        /* 
        @dev :This function code does is generate a unique ID for the request, based on randNonce, adds that ID to pendingRequests, 
        emits an event.
        The require statement at the top of the code will revert if the contract's 
        administrator has not yet added any data providers.

        @returns : It returns the ID
        */
        function requestRandomNumber() external returns (uint256) {
        require(numProviders > 0, " No data providers not yet added.");

        randNonce++;
        uint id = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000;
        pendingRequests[id] = true;

        emit RandomNumberRequested(msg.sender, id);
        return id;
    }

        /*
        @dev : returnRandomNumber is a public function which we'll restrict to the addresses with the PROVIDER_ROLE.  
        we ensure that the request ID is valid and then add the response to the array of responses for the request with this ID, stored in idToResponses. 
        We then store the length of the array in numResponses, 
        which we'll use to check if we've met the response threshold.
        In the next part we'll combine all the responses we receive and submit the result back to the caller.

        @params : Three arguments: the random number, the address that made the initial request, and the request ID.
         */
        function returnRandomNumber(uint256 randomNumber, address callerAddress, uint256 id) external onlyRole(PROVIDER_ROLE) {
        require(pendingRequests[id], "Request not found.");
        
        // Add newest response to list
        Response memory res = Response(msg.sender, callerAddress, randomNumber);
        idToResponses[id].push(res);
        uint numResponses = idToResponses[id].length;


           /*  The code in this if block will only run when the final data provider submits its random number. 
            It combines all the random numbers through a bitwise XOR, as taking an average would reduce the randomness. 
            It then deletes the data for this request – without this step, data providers could keep submitting different random numbers and changing the result. 
            It then fulfills the request by invoking the caller function's callback, and finally emits an event.
             */
        if (numResponses == providersThreshold) {
            uint compositeRandomNumber = 0;

            // Loop through the array and combine responses
            for (uint i=0; i < idToResponses[id].length; i++) {
                compositeRandomNumber = compositeRandomNumber ^ idToResponses[id][i].randomNumber; // bitwise XOR
            }
                
            // Clean up
            delete pendingRequests[id];
            delete idToResponses[id];
                
            // Fulfill request
            ICaller(callerAddress).fulfillRandomNumberRequest(compositeRandomNumber, id);
                
            emit RandomNumberReturned(compositeRandomNumber, callerAddress, id);
        }
    }

    /*
    @dev : This function is doing a duplication check, 
    it uses the _grantRole() function from AccessControl to assign PROVIDER_ROLE to the specified address, 
    increments numProviders, and emits an event to let users know of a contract configuration change.

    @params : It takes single argument provider address.
     */
    function addProvider(address provider) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!hasRole(PROVIDER_ROLE, provider), "Provider already added.");

        _grantRole(PROVIDER_ROLE, provider);
        numProviders++;

        emit ProviderAdded(provider);
    }

    /*
    @dev: This function performs the reverse operation of the addProvider function, 
    with an extra check to ensure that the administrator does not remove all providers from the contract, 
    rendering it unusable.

    @params : It takes single argument provider address
    
     */

        function removeProvider(address provider) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!hasRole(PROVIDER_ROLE, provider), "Address is not a recognized provider.");
        require (numProviders > 1, "Cannot remove the only provider.");

        _revokeRole(PROVIDER_ROLE, provider);
        numProviders--;

        emit ProviderRemoved(provider);
    }


    /* 
    @dev : This function is used to set the provider threshold and the finally emits the event ProviderThresholdChanged
    @params : It takes single uint threshold as an argument.
    
    */
        function setProvidersThreshold(uint threshold) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(threshold > 0, "Threshold cannot be zero.");

        providersThreshold = threshold;
        emit ProvidersThresholdChanged(providersThreshold);
    }


        // Events
    event RandomNumberRequested(address callerAddress, uint id);
    event RandomNumberReturned(uint256 randomNumber, address callerAddress, uint id);
    event ProviderAdded(address providerAddress);
    event ProviderRemoved(address providerAddress);
    event ProvidersThresholdChanged(uint threshold);

    
}