# Overdog Codex

This repository provides starter contracts, agent code, and deployment scripts for the **Overdog** protocol, an AI-driven meme token ecosystem.

## Structure

- `contracts/` – Solidity smart contracts
- `scripts/` – Hardhat deployment script
- `agents/` – Python agent skeleton for arbitrage and automation

## Quick Start

1. Install dependencies
   ```bash
   npm install
   ```
2. Compile contracts
   ```bash
   npx hardhat compile
   ```
3. Deploy to a network
   ```bash
   npx hardhat run scripts/deploy.js --network <network>
   ```
4. Run the Python agent
   ```bash
   pip install web3
   python agents/overdog_agent.py
   ```
