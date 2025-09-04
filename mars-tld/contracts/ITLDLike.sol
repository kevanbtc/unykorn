// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITLDLike {
    function tldName() external view returns (string memory);
    function applyParams(
        address _resolver,
        address _controller,
        address _feeModel,
        address _compliance,
        address _tbaImpl
    ) external;
}
