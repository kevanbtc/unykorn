// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FTHBaseToken.sol";

contract FTHEquityToken is FTHBaseToken {
    constructor() FTHBaseToken("FTHEquityToken", "FTEQ") {}
}

