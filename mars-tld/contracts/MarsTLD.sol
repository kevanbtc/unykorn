// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITLDLike.sol";

/**
 * @title MarsTLD
 * @dev Minimal TLD wrapper matching your .3 pattern.
 *      Params (resolver/controller/fee/compliance/tba) are set via applyParams().
 */
contract MarsTLD is ITLDLike {
    string public constant NAME = ".mars";

    address public immutable registry;
    address public resolver;
    address public controller;
    address public feeModel;
    address public compliance;
    address public tbaImpl; // ERC-6551 impl

    event ParamsApplied(address resolver, address controller, address feeModel, address compliance, address tbaImpl);

    constructor(address _registry) {
        require(_registry != address(0), "registry=0");
        registry = _registry;
    }

    function tldName() external pure returns (string memory) { return NAME; }

    function applyParams(
        address _resolver,
        address _controller,
        address _feeModel,
        address _compliance,
        address _tbaImpl
    ) external {
        resolver   = _resolver;
        controller = _controller;
        feeModel   = _feeModel;
        compliance = _compliance;
        tbaImpl    = _tbaImpl;
        emit ParamsApplied(_resolver, _controller, _feeModel, _compliance, _tbaImpl);
    }
}
