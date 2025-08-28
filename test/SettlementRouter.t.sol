// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/routers/SettlementRouter.sol";
import "../src/rails/MockChainRail.sol";

contract SettlementRouterTest is Test {
    SettlementRouter r;
    MockChainRail railA;
    MockChainRail railB;

    function setUp() public {
        r = new SettlementRouter();
        railA = new MockChainRail();
        railB = new MockChainRail();
    }

    function testAtomicDvPHappyPath() public {
        ISettlementRail.Hold memory h1 = ISettlementRail.Hold({
            id: keccak256("A"),
            payer: address(1),
            payee: address(2),
            asset: ISettlementRail.Asset({token: address(0), isoCode: "USD", decimals: 6}),
            amount: 1000,
            expiresAt: uint64(block.timestamp + 1 hours),
            railData: ""
        });
        ISettlementRail.Hold memory h2 = ISettlementRail.Hold({
            id: keccak256("B"),
            payer: address(3),
            payee: address(4),
            asset: ISettlementRail.Asset({token: address(0), isoCode: "EUR", decimals: 6}),
            amount: 900,
            expiresAt: uint64(block.timestamp + 1 hours),
            railData: ""
        });

        SettlementRouter.Leg memory L1 = SettlementRouter.Leg({rail: address(railA), hold: h1});
        SettlementRouter.Leg memory L2 = SettlementRouter.Leg({rail: address(railB), hold: h2});

        SettlementRouter.Order memory O = SettlementRouter.Order({
            id: keccak256("ORDER1"),
            debit: L1,
            credit: L2,
            deadline: uint64(block.timestamp + 1 hours)
        });

        bool ok = r.atomicDvP(O);
        assertTrue(ok, "DvP should succeed");
    }
}
