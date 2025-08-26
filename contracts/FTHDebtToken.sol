// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FTHBaseToken.sol";

contract FTHDebtToken is FTHBaseToken {
    constructor() FTHBaseToken("FTHDebtToken", "FTHD") {}
}

