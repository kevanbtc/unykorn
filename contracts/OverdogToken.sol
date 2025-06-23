// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title OverdogToken - Meme/Arb Token with burn and rewards
contract OverdogToken is ERC20, Ownable {
    uint256 public constant BPS_DIVISOR = 10000; // basis points divisor

    address public vault;
    address public pair;
    uint256 public launchTime;
    uint256 public constant SELL_BURN_BPS = 200; // 2%
    uint256 public constant SELL_REWARD_BPS = 100; // 1%
    uint256 public constant SELL_VAULT_BPS = 50; // 0.5%

    mapping(address => bool) public isBotExempt;

    event VaultUpdated(address indexed newVault);
    event PairUpdated(address indexed newPair);
    event Burn(address indexed from, uint256 amount);
    event RewardDistributed(address indexed from, uint256 amount);
    event VaultDeposit(address indexed from, uint256 amount);

    constructor(uint256 supply) ERC20("Overdog", "OVER") {
        _mint(msg.sender, supply);
    }

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
        emit VaultUpdated(_vault);
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
        emit PairUpdated(_pair);
    }

    function enableTrading() external onlyOwner {
        launchTime = block.timestamp;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(launchTime != 0, "Trading not enabled");
        // anti-bot: first 5 minutes only bots flagged allowed
        if(block.timestamp < launchTime + 5 minutes) {
            require(isBotExempt[to], "Transfers restricted");
        }

        uint256 burnAmt;
        uint256 rewardAmt;
        uint256 vaultAmt;

        if(to == pair) { // selling
            burnAmt = amount * SELL_BURN_BPS / BPS_DIVISOR;
            rewardAmt = amount * SELL_REWARD_BPS / BPS_DIVISOR;
            vaultAmt = amount * SELL_VAULT_BPS / BPS_DIVISOR;

            if(burnAmt > 0) {
                super._burn(from, burnAmt);
                emit Burn(from, burnAmt);
            }
            if(rewardAmt > 0) {
                super._transfer(from, address(this), rewardAmt);
                emit RewardDistributed(from, rewardAmt);
            }
            if(vaultAmt > 0 && vault != address(0)) {
                super._transfer(from, vault, vaultAmt);
                emit VaultDeposit(from, vaultAmt);
            }
        }

        uint256 remain = amount - burnAmt - rewardAmt - vaultAmt;
        super._transfer(from, to, remain);
    }
}
