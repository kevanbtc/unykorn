// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ICBDCSettlementGateway {
    function confirmSettlement(bytes32 settlementReference) external view returns (bool);
}

contract CBDCBridge is Ownable {
    IERC20 public immutable token;
    ICBDCSettlementGateway public gateway;

    struct LockInfo {
        address account;
        uint256 amount;
        bool redeemed;
    }

    mapping(bytes32 => LockInfo) public locks;
    mapping(address => uint256) public lockedBalances;

    event TokensLocked(address indexed account, uint256 amount, bytes32 indexed settlementRef);
    event TokensRedeemed(address indexed account, uint256 amount, bytes32 indexed settlementRef);

    constructor(address tokenAddress, address gatewayAddress) Ownable(msg.sender) {
        token = IERC20(tokenAddress);
        gateway = ICBDCSettlementGateway(gatewayAddress);
    }

    function setGateway(address gatewayAddress) external onlyOwner {
        gateway = ICBDCSettlementGateway(gatewayAddress);
    }

    function lock(uint256 amount, bytes32 settlementRef) external {
        require(amount > 0, "amount zero");
        require(locks[settlementRef].account == address(0), "ref used");
        require(token.transferFrom(msg.sender, address(this), amount), "transfer failed");

        locks[settlementRef] = LockInfo({account: msg.sender, amount: amount, redeemed: false});
        lockedBalances[msg.sender] += amount;

        emit TokensLocked(msg.sender, amount, settlementRef);
    }

    function redeem(bytes32 settlementRef) external {
        LockInfo storage info = locks[settlementRef];
        require(info.account == msg.sender, "not locker");
        require(!info.redeemed, "already redeemed");
        require(address(gateway) != address(0) && gateway.confirmSettlement(settlementRef), "settlement not confirmed");

        info.redeemed = true;
        lockedBalances[msg.sender] -= info.amount;
        require(token.transfer(msg.sender, info.amount), "transfer failed");

        emit TokensRedeemed(msg.sender, info.amount, settlementRef);
    }
}

