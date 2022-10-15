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
        uint256 id;
        address trader;
        Side side;
        bytes32 ticker;
        uint256 amount;
        uint256 price;
    }

    uint256 public nextOrderId = 0;

    // to keep order book for each assest
    // in first mapping bytes32 is the ticker of each asset
    // the secound mapping uint parameter points to Side (BUY or SELL)
    // Order[] is the order book
    mapping(bytes32 => mapping(uint256 => Order[])) public orderBook;

    // get list of order books based on ticker (asset name) and Side (BUY or SELL)
    function getOrderBook(bytes32 ticker, Side side) public view returns (Order[] memory) {
        return orderBook[ticker][uint256(side)];
    }

    function depositEth() public payable {
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(msg.value);
    }

    function createLimitOrder(Side side, bytes32 ticker, uint256 amount, uint256 price) public {
        if (side == Side.Buy) {
            require(balances[msg.sender]["ETH"] >= amount.mul(price));
        } else if (side == Side.SELL) {
            require(balances[msg.sender][ticker] >= amount);
        }

        Order[] storage orders = orderBook[ticker][uint256(side)];
        orders.push(
            Order(nextOrderId, msg.sender, side, ticker, amount, price)
        );

        // using Bubble Sort algorithm to sort by price
        // SELL is lowest to highest and BUY is highest to lowest
        uint256 i = orders.length > 0 ? orders.length-1 : 0;

        if (side == Side.Buy) {
            // using WHILE  to check if it is not the very first element of the order book
            while (i > 0) {
                // check if price of i-1 order is higher that i order
                if (orders[i-1].price > orders[i].price) {
                    // if condition is true, then the book is sorted truely
                    break;
                }
                // if order i price is higher than i-1 then must be swapped
                // put i-1 order into a temperory variable (used memory) to use it for swapping
                Order memory orderToMove = orders[i-1];
                orders[i-1] = orders[i];
                orders[i] = orderToMove;
                i--;
            }
        } else if (side == Side.SELL) {
            // using WHILE  to check if it is not the very first elemnt of the order book
            while (i > 0) {
                // check if price of i-1 order is lower that i order
                if (orders[i-1].price < orders[i].price) {
                    // if condition is true, then the book is sorted truely
                    break;
                }
                // if order i price is lower than i-1 then must be swapped
                // put i-1 order into a temperory variable (used memory) to use it for swapping
                Order memory orderToMove = orders[i-1];
                orders[i-1] = orders[i];
                orders[i] = orderToMove;
                i--;
            }
        }

        nextOrderId++;
    }
}
