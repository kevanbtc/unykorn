// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGlacierRegistry {
    // Adjust to your real registry ABI; this matches the read you used for `.3`
    function tldInfo(bytes32 tldHash) external view returns (
        address tldContract,
        address resolver,
        address controller,
        address feeModel,
        address compliance,
        address tbaImpl
    );

    // If your registry requires explicit registration, uncomment and use this:
//  function registerTLD(bytes32 tldHash, address tld) external;
}
