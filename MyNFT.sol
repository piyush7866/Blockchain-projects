// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/* 
@title : A smart contract for NFT auction
@author : Piyush Raj
@dev : authorized for the auction for NFT 
@notice: This program will perform the auction of NFT  bidding will take place and 
bid with the maximum bid value will be sold to the user

*/


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract MyAuction is IERC721Receiver {
    struct tokenDetails {
        address sellerAddress;
        uint128 priceOfArt;
        uint256 durationOfAuction;
        uint256 maxBid;
        address maxBidUser;
        bool isActive;
        uint256[] bidAmounts;
        address[] users;
    }

    mapping(address => mapping(uint256 => tokenDetails)) public tokenToAuction;

    mapping(address => mapping(uint256 => mapping(address => uint256))) public bids;
    
    /*
      @dev: Seller puts the item on auction 
    */
    function createTokenAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint128 _price,
        uint256 _duration
    ) external {
        require(msg.sender != address(0), "Invalid Address");
        require(_nftAddress != address(0), "Invalid Account");
        require(_price > 0, "Price should be more than 0");
        require(_duration > 0, "Invalid duration value");
        tokenDetails memory _auction = tokenDetails({
            sellerAddress: msg.sender,
            priceOfArt: uint128(_price),
            durationOfAuction: _duration,
            maxBid: 0,
            maxBidUser: address(0),
            isActive: true,
            bidAmounts: new uint256[](0),
            users: new address[](0)
        });
        address owner = msg.sender;
        ERC721(_nftAddress).safeTransferFrom(owner, address(this), _tokenId);
        tokenToAuction[_nftAddress][_tokenId] = _auction;
    }
    /*
      @dev:  Users bid for a particular nft, the max bid is compared and set if the current bid id highest
    */
    function bid(address _nft, uint256 _tokenId) external payable {
        tokenDetails storage auction = tokenToAuction[_nft][_tokenId];
        require(msg.value >= auction.priceOfArt, "bid price is less than current price");
        require(auction.isActive, "auction not active");
        require(auction.durationOfAuction > block.timestamp, "Deadline already passed");
        if (bids[_nft][_tokenId][msg.sender] > 0) {
            (bool success, ) = msg.sender.call{value :bids[_nft][_tokenId][msg.sender]}("");
            require(success);
        }
        bids[_nft][_tokenId][msg.sender] = msg.value;
        if (auction.bidAmounts.length == 0) {
            auction.maxBid = msg.value;
            auction.maxBidUser = msg.sender;
        } else {
            uint256 lastIndex = auction.bidAmounts.length - 1;
            require(auction.bidAmounts[lastIndex] < msg.value, "Current max bid is higher than your bid");
            auction.maxBid = msg.value;
            auction.maxBidUser = msg.sender;
        }
        auction.users.push(msg.sender);
        auction.bidAmounts.push(msg.value);
    }
    /*
       @dev: Called by the seller when the auction duration is over the hightest 
       bid user get's the nft and other bidders get eth back
    */
    function startSale(address _nft, uint256 _tokenId) external {
        tokenDetails storage auction = tokenToAuction[_nft][_tokenId];
        require(auction.durationOfAuction <= block.timestamp, "Deadline did not pass yet");
        require(auction.sellerAddress == msg.sender, "Not seller");
        require(auction.isActive, "auction not active");
        auction.isActive = false;
        if (auction.bidAmounts.length == 0) {
            ERC721(_nft).safeTransferFrom(
                address(this),
                auction.sellerAddress,
                _tokenId
            );
        } else {
            (bool success, ) = auction.sellerAddress.call{value : auction.maxBid }("");
            require(success);
            for (uint256 i = 0; i < auction.users.length; i++) {
                if (auction.users[i] != auction.maxBidUser) {
                    (success, ) = auction.users[i].call{
                        value : bids[_nft][_tokenId][auction.users[i]]
                    }("");
                    require(success);
                }
            }
            ERC721(_nft).safeTransferFrom(
                address(this),
                auction.maxBidUser,
                _tokenId
            );
        }
    }

    /**
       @dev : Called by the seller if they want to cancel the 
       auction for their nft so the bidders get back the locked eeth and the seller get's back the nft
    */
    function cancelAuction(address _nft, uint256 _tokenId) external {
        tokenDetails storage auction = tokenToAuction[_nft][_tokenId];
        require(auction.sellerAddress == msg.sender, "Not seller");
        require(auction.isActive, "auction not active");
        auction.isActive = false;
        bool success;
        for (uint256 i = 0; i < auction.users.length; i++) {
        (success, ) = auction.users[i].call{value : bids[_nft][_tokenId][auction.users[i]]}("");        
        require(success);
        }
        ERC721(_nft).safeTransferFrom(address(this), auction.sellerAddress, _tokenId);
    }

    /** 
    @dev : The function will return the token details in the auction .
    */
    function getTokenAuctionDetails(address _nft, uint256 _tokenId) public view returns (tokenDetails memory) {
        tokenDetails memory auction = tokenToAuction[_nft][_tokenId];
        return auction;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    )external  pure override returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    receive() external payable {}
}