pragma solidity 0.6.0;

/* 
@title : A smart contract for voting between Trump and Biden
@author : Piyush Raj
@dev : authorized the address voting for trump and biden
@notice: The program will give the results of  voting pool between trump and biden

*/

contract Voting{
    address  public contractOwner;
    uint TrumpVote;
    uint BidenVote;
    uint public startTime;
    uint public endTime;

    mapping (address => bool) alreadyVoted;

    /* here constructor will intialize the contract  */

    constructor(uint _startTime,uint _endTime) public {
        require(_startTime < _endTime);
        contractOwner = msg.sender;
        startTime = block.timestamp + _startTime;
        endTime = startTime + _endTime;
        
    }
    event pool (address from, string message, uint votes);

    /* 
    @dev in this function the voters will vote trump in the given time and checks if they already voted
    and also owner of the contract cannot vote.
    */

    function votingForTrump() public {
        require(block.timestamp >= startTime , "voting not started");
        require(block.timestamp <= endTime, "voting ended");
        require(!alreadyVoted[msg.sender],"already voted");
        require(msg.sender != contractOwner , "contract owner cannot not vote");
        TrumpVote += 1;
        alreadyVoted[msg.sender] = true;
        emit pool(msg.sender, "has given", TrumpVote);
    }


    /* 
    *@dev In this function the voters will vote biden in the given time and checks if they already voted and 
    also the owner of the contract cannot vote
    */

    function votingforBiden() public {
        require(block.timestamp >= startTime, "voting not started");
        require(block.timestamp <= endTime, "voting ended");
        require(!alreadyVoted[msg.sender], "already voted");
        require(msg.sender != contractOwner, "contract owner cannot vote");
        BidenVote += 1;
        alreadyVoted[msg.sender] = true;
        emit pool(msg.sender, "has given", BidenVote);
    }

    /* 
    @dev This function will calculate the total count of vote by adding trump and biden votes.
    */


    function voteCount() public view returns(uint) {
        uint countOfVote = BidenVote + TrumpVote;
        return (countOfVote);
    }

    /* 
    @dev The below function will calculate the winner of the voting pool by calculate the amount of vote by which 
    the candidate vote and also display the name of the winner
    */
    
    function winnerOfPoll() public view returns(string memory Win,uint byNumberOfVote) {
        require(block.timestamp >= endTime);
        if (TrumpVote > BidenVote) {
            return ("Winner is trump",(TrumpVote - BidenVote));
        }
        else if (BidenVote > TrumpVote) {
            return ("winner is Biden", (BidenVote - TrumpVote));
        }
        else if (BidenVote == TrumpVote) {
            return ("Its a tie", (BidenVote - TrumpVote));
        }
    }
}