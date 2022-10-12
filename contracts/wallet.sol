// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable {
    using SafeMath for uint256;

    struct Token {
        bytes32 ticker; // token identifier
        address tokenAddress;
    }

    // keeping list of tokens with full details
    mapping(bytes32 => Token) public tokenMapping;
    // add token tickers in a list
    bytes32[] public tokenList;

    // need double mapping for multiple balances
    mapping(address => mapping(bytes32 => uint256)) public balances;

    modifier tokenExist(bytes32 ticker) {
        // check if token exists
        require(tokenMapping[ticker].tokenAddress != address(0), "Token does not exist");
        _;
    }
    
    // onlyOwner added to just permit the contract owner to add new token
    function addToken(bytes32 ticker, address tokenAddress) onlyOwner external {
        // create new token
        tokenMapping[ticker] = Token(ticker, tokenAddress);

        // add to token list
        tokenList.push(ticker);
    }

    function deposit(uint amount, bytes32 ticker) tokenExist(ticker) external {
        // trasfer amount from user to our contract address
        IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
        // add amount to user wallet
        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);
    }

    function withdraw(uint amount, bytes32 ticker) tokenExist(ticker) external {
        // check if user balance is enough
        require(balances[msg.sender][ticker] >= amount, "Balance not sufficient");

        // decrease amount from user wallet balance
        // balance kept in a bouble mapping
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);

        // sending specified token (tokenMapping[ticker].tokenAddress) to the user (msg.sender) with specified amount
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount);
    }
}