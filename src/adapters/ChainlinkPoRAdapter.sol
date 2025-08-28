// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IProofOfReserveOracle} from "../interfaces/IProofOfReserveOracle.sol";

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
    function decimals() external view returns (uint8);
}

contract ChainlinkPoRAdapter is IProofOfReserveOracle {
    AggregatorV3Interface public immutable feed;
    uint256 public immutable staleAfter;

    constructor(address _feed, uint256 _staleAfter) {
        require(_feed != address(0), "feed=0");
        require(_staleAfter > 0, "staleAfter=0");
        feed = AggregatorV3Interface(_feed);
        staleAfter = _staleAfter;
    }

    function collateralValueUSD18() external view override returns (uint256) {
        (, int256 answer, , uint256 updatedAt, ) = feed.latestRoundData();
        require(answer >= 0, "neg");
        uint8 d = feed.decimals();
        uint256 val = uint256(answer);
        if (d < 18) val *= 10 ** (18 - d);
        else if (d > 18) val /= 10 ** (d - 18);
        require(block.timestamp - updatedAt <= staleAfter, "stale");
        return val;
    }

    function lastUpdateTs() external view override returns (uint64) {
        (, , , uint256 updatedAt, ) = feed.latestRoundData();
        return uint64(updatedAt);
    }

    function isValid() external view override returns (bool) {
        (, , , uint256 updatedAt, ) = feed.latestRoundData();
        return block.timestamp - updatedAt <= staleAfter;
    }
}
