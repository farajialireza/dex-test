// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./wallet.sol";

contract Dex is Wallet {
    enum Side {
        Buy,
        SELL
    }

    struct Order {
        uint id;
        address trader;
        bool buyOrder;
        bytes32 ticker;
        uint amount;
        uint price;
    }

    // to keep order book for each assest
    // in first mapping bytes32 is the ticker of each asset
    // the secound mapping uint parameter points to Side (BUY or SELL)
    // Order[] is the order book
    mapping(bytes32 => mapping(uint => Order[])) orderBook;

    // get list of order books based on ticker (asset name) and Side (BUY or SELL)
    function getOrderBook(bytes32 ticker, Side side) view public returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }
}