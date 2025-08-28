// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ISettlementRail} from "../routers/ISettlementRail.sol";

abstract contract CBDCRailBase is ISettlementRail {
    address public immutable gateway;
    mapping(bytes32 => HoldStatus) public _status;

    constructor(address _gw){ require(_gw!=address(0)); gateway=_gw; }

    modifier onlyGateway(){ require(msg.sender==gateway, "gw"); _; }

    function rail() external pure returns (RailType){ return RailType.CBDC; }

    function placeHold(Hold calldata h) external returns (bytes32){
        bytes32 id = h.id;
        _status[id] = HoldStatus.PENDING;
        _requestHoldOffchain(h);
        return id;
    }

    function commit(bytes32 id) external returns (bool){ _requestCommitOffchain(id); return true; }
    function release(bytes32 id) external returns (bool){ _requestReleaseOffchain(id); return true; }
    function status(bytes32 id) external view returns (HoldStatus){ return _status[id]; }

    function onHeld(bytes32 id) external onlyGateway { _status[id]=HoldStatus.HELD; }
    function onCommitted(bytes32 id) external onlyGateway { _status[id]=HoldStatus.COMMITTED; }
    function onReleased(bytes32 id) external onlyGateway { _status[id]=HoldStatus.RELEASED; }
    function onFailed(bytes32 id) external onlyGateway { _status[id]=HoldStatus.FAILED; }

    function _requestHoldOffchain(Hold calldata h) internal virtual;
    function _requestCommitOffchain(bytes32 id) internal virtual;
    function _requestReleaseOffchain(bytes32 id) internal virtual;
}
