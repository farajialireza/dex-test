// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Link is ERC20 {
    constructor() ERC20("Chainlink", "LINK") {
        _mint(msg.sender, 1000);
    }
}