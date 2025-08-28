# Deployment & Validation Checklist

This runbook documents the end‑to‑end steps for deploying the Digital Giant x MOG contracts and verifying that ownership is transferred to a multisig.

## 1. Environment preparation

1. Copy the example environment and fill in values:
   ```bash
   cp .env.example .env
   # Set RPC_URL, PRIVATE_KEY, PINATA_JWT, MULTISIG_SAFE
   ```
2. Install dependencies:
   ```bash
   npm install
   ```

## 2. Compile and test

1. Compile contracts:
   ```bash
   npm run build
   ```
   Compilation must succeed before deploying.
2. Run tests:
   ```bash
   npm test
   ```

## 3. Deployment

1. Deploy contracts with the production script:
   ```bash
   node scripts/deploy.js
   ```
2. Record output addresses for the registry, compliance layer and settlement bus.

## 4. Ownership validation

1. For each deployed contract, confirm the owner is the multisig:
   ```bash
   npx hardhat console --network mainnet
   > const Contract = await ethers.getContractAt("Ownable", "<ADDRESS>");
   > await Contract.owner();
   ```
2. Ensure the returned address matches `MULTISIG_SAFE` from `.env`.

## 5. Post‑deployment checks

- Verify the contracts on the block explorer.
- Store deployment artifacts and addresses in `docs/` or an internal registry.
- Notify the compliance council of new contract addresses.

## 6. Troubleshooting

- If compilation fails with a compiler download error, pin a specific solc version in `hardhat.config.js` or install `solc` locally.
- If tests or deployment scripts fail, run with `--show-stack-traces` for more context.

This checklist ensures every deployment is reproducible and all contracts are secured by the designated multisig.
