// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISettlementRail} from "./ISettlementRail.sol";

contract SettlementRouter {
    event AtomicDvP(bytes32 indexed orderId, bytes32 debitHold, bytes32 creditHold, bool committed);

    struct Leg { address rail; ISettlementRail.Hold hold; }
    struct Order { bytes32 id; Leg debit; Leg credit; uint64 deadline; }

    mapping(bytes32 => bool) public settled;

    function atomicDvP(Order calldata o) external returns (bool) {
        require(block.timestamp <= o.deadline, "expired");
        require(!settled[o.id], "done");

        bytes32 debitHold = ISettlementRail(o.debit.rail).placeHold(o.debit.hold);
        bytes32 creditHold = ISettlementRail(o.credit.rail).placeHold(o.credit.hold);

        bool ok = _commitBoth(o.debit.rail, debitHold, o.credit.rail, creditHold);
        emit AtomicDvP(o.id, debitHold, creditHold, ok);
        settled[o.id] = ok;
        return ok;
    }

    function _commitBoth(address rA, bytes32 hA, address rB, bytes32 hB) internal returns (bool) {
        ISettlementRail R1 = ISettlementRail(rA);
        ISettlementRail R2 = ISettlementRail(rB);
        if (R1.status(hA) == ISettlementRail.HoldStatus.HELD && R2.status(hB) == ISettlementRail.HoldStatus.HELD) {
            bool c1 = R1.commit(hA);
            bool c2 = R2.commit(hB);
            if (c1 && c2) return true;
        }
        R1.release(hA);
        R2.release(hB);
        return false;
    }
}
