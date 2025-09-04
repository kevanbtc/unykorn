# Unykorn Smart Contract Platform

Unykorn is a cross-chain token launch factory built with Solidity smart contracts for NFT marketplace, staking, and token functionality. The repository uses Hardhat for development and testing with a pnpm monorepo structure.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Initial Setup and Dependencies
- Install dependencies: `npm install` -- takes 55 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
- Environment setup: Copy `.env.template` to `.env` and configure `RPC_URL` and `PRIVATE_KEY` for network deployment
- Node.js v20.19.4 and npm v10.8.2 are required and already available

### Core Development Commands
- Clean build artifacts: `npm run clean` -- removes cache and artifacts (1 second)
- Compile contracts: `npm run compile` -- takes 10 seconds from clean state. NEVER CANCEL. Set timeout to 60+ seconds.
- Run tests: `npm run test` -- takes 3 seconds. NEVER CANCEL. Set timeout to 30+ seconds.
- Generate coverage: `npm run coverage` -- takes 9 seconds. NEVER CANCEL. Set timeout to 60+ seconds.

### Additional Hardhat Commands
- Start local blockchain: `npx hardhat node` -- runs development blockchain on port 8545
- Run deployment scripts: `npx hardhat run scripts/[script].js --network [network]` -- takes 2-3 seconds
- Open Hardhat console: `npx hardhat console --network [network]` -- for interactive contract testing
- Flatten contracts for verification: `npx hardhat flatten contracts/[Contract].sol`
- View available tasks: `npx hardhat help`

## Known Issues and Workarounds

### Security Audit Issues
- `npm audit` reports 16 low severity vulnerabilities -- these are from Hardhat dependencies and do not affect functionality
- Dependencies are locked via `package-lock.json` -- do not run `npm audit fix` unless specifically required

### Contract Deployment
- The original `scripts/deploy.js` is outdated for ethers v6 -- use `scripts/deploy-fixed.js` as reference
- Use `await contract.waitForDeployment()` instead of `await contract.deployed()` for ethers v6
- Use `await contract.getAddress()` instead of `contract.address` for ethers v6

### Compilation Warnings
- Compilation produces warnings about missing SPDX license identifiers -- these are safe to ignore
- Shadow declaration warning in `MerkleLib.sol` -- known issue, does not affect functionality

## Validation and Testing

### ALWAYS run these validation steps after making changes:
1. **Compile**: `npm run compile` -- must complete without errors
2. **Test**: `npm run test` -- all tests must pass
3. **Coverage**: `npm run coverage` -- ensure new code has adequate test coverage
4. **Deploy Test**: Test deployment script on hardhat network to verify contract integration

### Manual Validation Scenarios
After making contract changes, ALWAYS test:
1. **Basic deployment**: Deploy contracts to hardhat network using corrected deployment pattern
2. **Token functionality**: Test minting, transfers, and access controls for token contracts
3. **Marketplace functions**: Test listing, purchasing, and fee collection if modifying marketplace
4. **Staking mechanics**: Test stake/unstake operations if modifying staking contracts
5. **Upgrade patterns**: Verify UUPS upgrade functionality for upgradeable contracts

### Test Contract Deployment Example
```javascript
const [deployer] = await hre.ethers.getSigners();
const VTV = await hre.ethers.getContractFactory("VTV");
const vtv = await VTV.deploy();
await vtv.waitForDeployment();
console.log("VTV deployed to:", await vtv.getAddress());
```

## Repository Structure

### Key Directories
- `contracts/` -- Solidity smart contracts
  - `evm/` -- EVM-specific contracts (TokenERC20, LiquidityHelper, MemePass721)
  - `shared/` -- Shared libraries (MerkleLib)
  - Root contracts: NFTMarketplace, NFTStaking, VTV, VCHAN, VPOINT, etc.
- `test/` -- Contract test files (currently TokenERC20.test.js)
- `scripts/` -- Deployment and utility scripts
- `apps/` -- Placeholder frontend/backend applications (not implemented)
- `cli/` -- Placeholder command-line tools for EVM and Solana
- `docs/` -- Documentation including security audit and architecture

### Important Contracts
- `VTV.sol` -- Basic ERC-20 utility token with pause/burn functionality
- `VCHAN.sol` -- Governance token
- `VPOINT.sol` -- Soulbound loyalty points (non-transferable)
- `TokenERC20.sol` -- Upgradeable ERC-20 with roles, permits, and launch lock
- `NFTMarketplace.sol` -- ERC-721 marketplace with fees
- `NFTStaking.sol` -- NFT staking for ETH rewards
- `SubscriptionVault.sol` -- Monthly subscription using ERC-20
- `AffiliateRouter.sol` -- Referral commission system

### Configuration Files
- `hardhat.config.cjs` -- Hardhat configuration with solidity 0.8.24, forced local compiler
- `package.json` -- Project dependencies and npm scripts
- `pnpm-workspace.yaml` -- Monorepo workspace configuration
- `.env.template` -- Environment variable template

## Common Tasks and Time Expectations

### Build Operations (NEVER CANCEL - Always set appropriate timeouts)
- Fresh npm install: 55 seconds (includes dependency warnings)
- Clean compilation: 10 seconds
- Test suite execution: 3 seconds
- Coverage generation: 9 seconds
- Contract deployment: 2-3 seconds per contract

### Frequently Accessed Files
```
ls [repo-root]
.env.template  README.md      cli/           docs/          package.json   samples/       test/
.gitignore     apps/          contracts/     hardhat.config.cjs  pnpm-workspace.yaml  scripts/

ls contracts/
AffiliateRouter.sol  NFTMarketplace.sol   VCHAN.sol   evm/
AuditTrail.sol       NFTStaking.sol       VPOINT.sol  shared/
SubscriptionVault.sol VTV.sol             solana/
```

### package.json scripts
```json
{
  "scripts": {
    "clean": "rm -rf cache artifacts",
    "compile": "hardhat compile", 
    "test": "hardhat test --parallel",
    "coverage": "hardhat coverage"
  }
}
```

## Development Guidelines

### Before Committing Changes
- ALWAYS run `npm run test` to ensure all tests pass
- ALWAYS run `npm run compile` to verify contracts compile without errors
- Consider running `npm run coverage` to check test coverage impact
- Test deployment patterns if modifying contracts

### Technology Stack
- **Smart Contracts**: Solidity 0.8.24 with OpenZeppelin libraries
- **Development**: Hardhat with ethers.js v6
- **Testing**: Mocha/Chai with Hardhat network helpers
- **Architecture**: UUPS upgradeable patterns, role-based access control
- **Package Management**: npm with locked dependencies

### Performance Expectations
- **CRITICAL**: All build operations complete quickly (under 60 seconds)
- Compilation warnings about SPDX licenses are normal and safe to ignore
- npm audit vulnerabilities are from development dependencies and non-critical
- Test execution is fast due to parallel execution flag

### Limitations
- Frontend/backend applications are placeholders only
- CLI tools are not yet implemented
- No CI/CD workflows configured
- Deploy script requires manual fixes for ethers v6 compatibility