// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IProofOfReserveOracle {
    function collateralValueUSD18() external view returns (uint256);
    function lastUpdateTs() external view returns (uint64);
    function isValid() external view returns (bool);
}
