// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IAFOEngine.sol";
interface IERC20 { function transferFrom(address,address,uint256) external returns (bool); }
interface IERC721 { function safeTransferFrom(address,address,uint256) external; }

contract OISW {
    IAFOEngine public afo;
    event SettledDvP(address buyer, address seller, address cash, address asset, uint256 amt, uint256 tokenId, bytes32 receipt);

    constructor(address _afo) { afo = IAFOEngine(_afo); }

    struct DvP {
        address cashToken;      // ERC20 (e.g., VaultUSD.t)
        address assetToken;     // ERC721 (vaulted asset)
        address buyer;
        address seller;
        uint256 cashAmount;
        uint256 assetId;        // ERC721 tokenId
        bytes32 policyId;
        bytes    proofs;        // zk / IPFS refs
    }

    function settleDvP(DvP calldata p) external returns (bytes32 receiptCid) {
        // 1) Preflight (compliance/tax/limits/etc.)
        (bool ok,) = afo.preflight(IAFOEngine.Preflight({
            buyer: p.buyer,
            seller: p.seller,
            asset: p.assetToken,
            price: p.cashAmount,
            policyId: p.policyId,
            proofCID: p.proofs
        }));
        require(ok, "AFO:blocked");

        // 2) Cash leg: buyer -> seller
        require(IERC20(p.cashToken).transferFrom(p.buyer, p.seller, p.cashAmount), "cash xfer fail");

        // 3) Asset leg: seller -> buyer (ERC721)
        IERC721(p.assetToken).safeTransferFrom(p.seller, p.buyer, p.assetId);

        // 4) Emit receipt (placeholder: hash over params)
        receiptCid = keccak256(abi.encodePacked(p.buyer,p.seller,p.cashToken,p.assetToken,p.cashAmount,p.assetId,p.policyId,p.proofs));
        emit SettledDvP(p.buyer,p.seller,p.cashToken,p.assetToken,p.cashAmount,p.assetId,receiptCid);
    }
}
