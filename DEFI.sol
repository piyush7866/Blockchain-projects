// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
@title : A DEFI exchange smart contract which is used for exchanging token to ether and vice-versa.
@author : Piyush Raj
@dev : The contract is authorized to buy and sell the NeoTokens and spend and receive ether on behalf of token.
@notice: The program will buy and sell the neotokens.

*/

//@dev : Declaring ERC20 interface
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract NeoToken is IERC20 {

    //Intializing the name of the token ,symbol and decimal place.
    string public constant name = "NeoToken";
    string public constant symbol = "NET";
    uint8 public constant decimals = 18;


    //@dev : balances mapping is used to store the balance of token crossponding to a particular address.
    mapping(address => uint256) balances;

    // @dev: allowed mapping is used to store the address which is allowed to reterive the token amount.
    mapping(address => mapping (address => uint256)) allowed;

    //@dev: Total supply of token is intializied to 10 ether.
    uint256 _totalSupply = 10 ether;


   constructor() {
    // Intializing the balance of the user with 10 ether
    balances[msg.sender] = _totalSupply;
    }

    //@dev : Getter function use to check the total supply of the token .
    //@returns : it returns uint256.
    function totalSupply() public override view returns (uint256) {
    return _totalSupply;
    }

    //@dev: Getter function used to check the balance of the tokenOwner.
    //@params : It takes address of tokenOwner.
    //@returns : It returns uint256.
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    /* 
    @dev :  This function overrides the transfer function of IERC20 , first it checks if user have enough balance
    to transfer or not. Then the number of token is subtracted from the balnce of the sender and those number of token is
    then added to the balance of the receiver.

    @params: It takes receiver address and number of tokens as arguments.
    @returns : It returns a boolean.
    */
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    /* 
    @dev: This function overrides the approve function of IERC20 interface.
    First it saves the number of tokens in the allowed mapping and then it emits the event Approval.

    @params: It takes the address of the delegate and number of tokes as an argumet
    @returns : It returns boolean value.
    */
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    //@dev : This getter returns the remaining number of tokens that the spender will be allowed to spend on behalf of owner
    //@returns : It returns a uint.
    //@params: It takes address of owner and delegate as a parameter.
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    /*
    @dev: This function transferFrom overrides IERC20 transferFrom function.
    First it checks the balance of the owner and then it checks if this amount is allowed to tranfer or not.
    Then after that , the amount of token is deducted from the owner balance and same amount is added to the buyer balance.
    And then it emits Transfer event.

    @params: It takes owner address, buyer address and number of tokens.
    @retruns: It returns boolean value.
    */
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

contract DecentralizedExchange {

    //Declaring Bought and Sold events.
    event Bought(uint256 amount);
    event Sold(uint256 amount);


    IERC20 public token;

    constructor() {
        // Intializing the token in the constructor
        token = new NeoToken();
    }

    /*
    @dev: This function buyToken will buy the tokens , first we intializes the amount to buy and balance ,
    then checks if the amount is greater than zero or not and also checks if the amount to buy is less than or equal to the
    balance or not. After that we transfer the token to the user and then emit the Bought event.

    */
    function buyToken() payable public {
        uint256 amountTobuy = msg.value;
        uint256 Balance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= Balance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }
    /*
    @dev: This function sellToken is used to sell the token and get corresponding ether back,first it checks if the 
    amount is greater than zero or not after that allowance valible is intialized and then we check if the allowance 
    variable value is greater than the amount value.Then we use transferFrom function of the token and send the ether
    back to the user and the token is then trasfer back to the owner and then we emit sold event .

    @params: It takes amount as an argument.
    */
    function sellToken(uint256 amount) public payable {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }

}
