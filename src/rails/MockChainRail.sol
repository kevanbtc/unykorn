// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISettlementRail} from "../routers/ISettlementRail.sol";

contract MockChainRail is ISettlementRail {
    mapping(bytes32 => HoldStatus) public _status;
    function rail() external pure returns (RailType){ return RailType.PUBLIC_CHAIN; }
    function supportsAsset(Asset calldata) external pure returns (bool){ return true; }

    function placeHold(Hold calldata h) external returns (bytes32){
        _status[h.id] = HoldStatus.HELD;
        return h.id;
    }
    function commit(bytes32 id) external returns (bool){ _status[id] = HoldStatus.COMMITTED; return true; }
    function release(bytes32 id) external returns (bool){ _status[id] = HoldStatus.RELEASED; return true; }
    function status(bytes32 id) external view returns (HoldStatus){ return _status[id]; }
}
