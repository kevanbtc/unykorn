// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./IAFOEngine.sol";
contract MockAFO is IAFOEngine {
    function preflight(Preflight calldata) external pure returns (bool ok, bytes memory memo) {
        return (true, bytes("OK"));
    }
}
