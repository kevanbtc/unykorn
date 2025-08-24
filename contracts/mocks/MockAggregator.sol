// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAggregator {
    int256 public answer;

    constructor(int256 _answer) {
        answer = _answer;
    }

    function latestAnswer() external view returns (int256) {
        return answer;
    }
}
