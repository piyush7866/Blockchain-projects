pragma solidity 0.6.0;

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

    /*  This function will calculate the votes for Trump */
    function votingForTrump() public {
        require(block.timestamp >= startTime , "voting not started");
        require(block.timestamp <= endTime, "voting ended");
        require(!alreadyVoted[msg.sender],"already voted");
        require(msg.sender != contractOwner , "contract owner cannot not vote");
        TrumpVote += 1;
        alreadyVoted[msg.sender] = true;
    }

    /*  This function will calculate the votes for biden*/
    function votingforBiden() public {
        require(block.timestamp >= startTime, "voting not started");
        require(block.timestamp <= endTime, "voting ended");
        require(!alreadyVoted[msg.sender], "already voted");
        require(msg.sender != contractOwner, "contract owner cannot vote");
        BidenVote += 1;
        alreadyVoted[msg.sender] = true;
    }

    /* This function will calculate the total vote count  */ 
    function voteCount() public view returns(uint totalVote) {
        uint countOfVote = BidenVote + TrumpVote;
        return (countOfVote);
    }

    /*  This function will calculate  who is the winner */
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