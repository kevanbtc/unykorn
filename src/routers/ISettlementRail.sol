// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ISettlementRail {
    enum RailType { CBDC, USC, RTGS, SEPA, SWIFT, PUBLIC_CHAIN }
    enum HoldStatus { NONE, PENDING, HELD, COMMITTED, RELEASED, FAILED }

    struct Asset { address token; string isoCode; uint8 decimals; }
    struct Hold {
        bytes32 id;
        address payer;
        address payee;
        Asset asset;
        uint256 amount;
        uint64  expiresAt;
        bytes   railData;
    }

    function rail() external view returns (RailType);
    function supportsAsset(Asset calldata a) external view returns (bool);

    function placeHold(Hold calldata h) external returns (bytes32 holdId);
    function commit(bytes32 holdId) external returns (bool);
    function release(bytes32 holdId) external returns (bool);
    function status(bytes32 holdId) external view returns (HoldStatus);
}
