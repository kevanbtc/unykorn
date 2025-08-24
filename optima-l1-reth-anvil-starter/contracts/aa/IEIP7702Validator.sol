// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
interface IEIP7702Validator {
    function validateDelegation(address eoa, bytes calldata sig, bytes calldata execCalldata)
        external returns (bool);
}
