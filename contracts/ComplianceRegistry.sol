// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ComplianceRegistry is Ownable {
    struct Participant {
        bool kycPassed;
        bool amlPassed;
    }

    mapping(address => Participant) private participants;

    function setKycPassed(address account, bool passed) external onlyOwner {
        participants[account].kycPassed = passed;
    }

    function setAmlPassed(address account, bool passed) external onlyOwner {
        participants[account].amlPassed = passed;
    }

    function isKycPassed(address account) public view returns (bool) {
        return participants[account].kycPassed;
    }

    function isAmlPassed(address account) public view returns (bool) {
        return participants[account].amlPassed;
    }

    function isCompliant(address account) public view returns (bool) {
        Participant memory p = participants[account];
        return p.kycPassed && p.amlPassed;
    }
}
