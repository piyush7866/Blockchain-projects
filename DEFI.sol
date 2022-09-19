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

interface IUniswap{
    function swapExactTokenForETH(uint amountIn,
    uint amountOutMin, 
    address[] calldata path,
    address to,
    uint deadline) external
    returns (uint[] memory amounts);

    function WETH() external pure returns (address);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

}

contract DecentralizedExchange {

    //Declaring Bought and Sold events.
    event Bought(uint256 amount);
    event Sold(uint256 amount);

    IUniswap public uniswap;

    constructor(address _uniswap) {
        // Intializing the token in the constructor
        uniswap = IUniswap(_uniswap);
    }

   
    function swapTokenForETH(address token,uint amountIn,uint amountOutMin, uint deadline)
    external {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokenForETH(amountIn, amountOutMin,path,msg.sender, deadline);
    }

    function swapETHForToken(address token, uint amountIn, uint amountOutMin, uint deadline) external {
        IERC20(token).transferFrom(address(this), msg.sender, amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).approve(msg.sender, amountIn);
        uniswap.swapETHForExactTokens(amountOutMin,path,address(this),deadline);
    }

}
