// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
interface IPaymasterPolicy {
    function acceptUserOp(address sender, bytes calldata userOp, bytes32 policyId)
        external returns (bool ok, uint256 maxGasPaid);
}
