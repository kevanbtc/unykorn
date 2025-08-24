// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Compliance Registry
/// @notice Stores investor accreditation, jurisdiction data and tracks foreign investment limits.
contract ComplianceRegistry is Ownable {
    mapping(address => bool) public kycCompleted;
    mapping(address => bool) public foreignInvestor;
    mapping(address => uint256) public foreignInvestment;

    uint256 public investorCount;
    uint256 public maxInvestors = 200;

    uint256 public fxLimitPerInvestor;
    uint256 public maxTotalForeignInvestment;
    uint256 public totalForeignInvestment;

    event InvestorWhitelisted(address investor, bool isForeign, string jurisdiction);
    event ForeignInvestmentRecorded(
        address investor,
        uint256 amount,
        uint256 investorTotal,
        uint256 aggregateForeignTotal
    );
    event FXLimitBreached(address investor, uint256 attemptedAmount, uint256 limit);

    /// @notice Add an investor to the registry.
    /// @param investor address of the investor
    /// @param isForeign whether the investor is considered foreign under FEMA
    /// @param jurisdiction ISO jurisdiction code (e.g., "IN")
    function addInvestor(address investor, bool isForeign, string memory jurisdiction) external onlyOwner {
        require(!kycCompleted[investor], "Already added");
        require(investorCount < maxInvestors, "Max investor limit reached");
        kycCompleted[investor] = true;
        foreignInvestor[investor] = isForeign;
        investorCount++;
        emit InvestorWhitelisted(investor, isForeign, jurisdiction);
    }

    /// @notice Remove investor from registry.
    function removeInvestor(address investor) external onlyOwner {
        require(kycCompleted[investor], "Not registered");
        if (foreignInvestor[investor]) {
            totalForeignInvestment -= foreignInvestment[investor];
            foreignInvestment[investor] = 0;
            foreignInvestor[investor] = false;
        }
        kycCompleted[investor] = false;
        investorCount--;
    }

    /// @notice Check if an address has completed KYC.
    function isCompliant(address investor) external view returns (bool) {
        return kycCompleted[investor];
    }

    /// @notice Set maximum allowed investment per foreign investor.
    function setFXLimitPerInvestor(uint256 limit) external onlyOwner {
        fxLimitPerInvestor = limit;
    }

    /// @notice Set maximum aggregate foreign investment allowed for the offering.
    function setMaxTotalForeignInvestment(uint256 limit) external onlyOwner {
        maxTotalForeignInvestment = limit;
    }

    /// @notice Records incoming investment for an address and enforces FX limits.
    /// @dev Meant to be called by token contracts during mint or transfer.
    function checkAndRecordForeignInvestment(address investor, uint256 amount) external {
        if (!kycCompleted[investor] || !foreignInvestor[investor]) {
            return; // nothing to track for domestic investors
        }

        uint256 newInvestorTotal = foreignInvestment[investor] + amount;
        if (fxLimitPerInvestor != 0 && newInvestorTotal > fxLimitPerInvestor) {
            emit FXLimitBreached(investor, amount, fxLimitPerInvestor);
            revert("FX limit per investor exceeded");
        }

        uint256 newTotalForeign = totalForeignInvestment + amount;
        if (maxTotalForeignInvestment != 0 && newTotalForeign > maxTotalForeignInvestment) {
            emit FXLimitBreached(investor, amount, maxTotalForeignInvestment);
            revert("Total foreign investment limit exceeded");
        }

        foreignInvestment[investor] = newInvestorTotal;
        totalForeignInvestment = newTotalForeign;
        emit ForeignInvestmentRecorded(investor, amount, newInvestorTotal, newTotalForeign);
    }
}

