// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side {
        Buy,
        SELL
    }

    struct Order {
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
    }

    // to keep order book for each assest
    // in first mapping bytes32 is the ticker of each asset
    // the secound mapping uint parameter points to Side (BUY or SELL)
    // Order[] is the order book
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    // get list of order books based on ticker (asset name) and Side (BUY or SELL)
    function getOrderBook(bytes32 ticker, Side side) view public returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public {
        if(side == Side.Buy) {
            require(balances[msg.sender]["ETH"] >= amount.mul(price), "ETH balance is not enough");
        }
    }
}