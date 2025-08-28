// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IZkReserves {
    function verify(bytes calldata proof, bytes32 portfolioCommit, uint256 liabilities, uint64 asOf) external view returns (bool);
}
