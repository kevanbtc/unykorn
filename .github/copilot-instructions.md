# Unykorn Smart Contract Development

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

Unykorn is a cross-chain token launch factory built with Hardhat for Solidity smart contract development. It includes EVM contracts for token creation, NFT marketplace, staking, and subscription management, plus placeholder infrastructure for backend services.

## Working Effectively

### Initial Setup and Dependencies
- **REQUIRED: Node.js v20+ and npm v10+** are already installed
- Run `npm install` -- takes 60 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
- The repository uses npm (not pnpm) despite having pnpm-workspace.yaml
- Copy `.env.template` to `.env` and configure RPC_URL and PRIVATE_KEY for network deployments

### Core Development Workflow
Always run these commands in sequence for any smart contract work:
1. `npm run clean` -- instant, removes artifacts and cache
2. `npm run compile` -- takes 10 seconds. NEVER CANCEL. Set timeout to 30+ seconds.
3. `npm run test` -- takes 3 seconds. NEVER CANCEL. Set timeout to 30+ seconds.
4. `npm run coverage` -- takes 10 seconds. NEVER CANCEL. Set timeout to 30+ seconds.

### Deployment and Scripts
- `npx hardhat run scripts/deploy.js` -- takes 11 seconds, deploys VTV, VCHAN, and VPOINT tokens
- `npx hardhat run scripts/deploy.js --network yourNetwork` -- for specific networks (requires .env setup)
- Deploy script works with ethers v6 (uses `waitForDeployment()` and `getAddress()`)

### Key Commands and Timing
- `npm install`: 60 seconds - NEVER CANCEL, timeout 120+ seconds
- `npm run compile`: 10 seconds - NEVER CANCEL, timeout 30+ seconds  
- `npm run test`: 3 seconds - NEVER CANCEL, timeout 30+ seconds
- `npm run coverage`: 10 seconds - NEVER CANCEL, timeout 30+ seconds
- `npx hardhat run scripts/deploy.js`: 11 seconds - NEVER CANCEL, timeout 30+ seconds

## Validation and Testing

### Smart Contract Validation Scenarios
After making any contract changes, ALWAYS run this complete validation sequence:
1. `npm run clean && npm run compile` -- verify compilation succeeds
2. `npm run test` -- ensure existing tests pass (2 tests currently)
3. `npm run coverage` -- verify coverage reports generate
4. `npx hardhat run scripts/deploy.js` -- test deployment works

### Manual Testing Requirements
When modifying smart contracts, ALWAYS test these scenarios:
- **Token Transfer Lock**: Verify TokenERC20 enforces 7-day launch lock on transfers
- **Initial Supply**: Confirm 1 billion tokens minted to deployer on initialization
- **Upgradeable Patterns**: Test UUPS upgrade authorization (owner-only)
- **Role-Based Access**: Verify MINTER_ROLE, BURNER_ROLE, PAUSER_ROLE function correctly

### Expected Test Results
- TokenERC20 tests: 2 passing (mints initial supply, enforces launch lock)
- Coverage: ~15% overall (only TokenERC20 has tests currently)
- Warnings: SPDX license missing in NFTMarketplace.sol, NFTStaking.sol; shadowing in MerkleLib.sol

## Repository Structure and Navigation

### Key Directories
```
contracts/           - Solidity contracts (main focus)
├── evm/            - EVM-specific contracts (TokenERC20, MemePass721, LiquidityHelper)
├── shared/         - Shared libraries (MerkleLib)
├── solana/         - Solana contracts (placeholder)
test/               - Mocha/Chai test files (TokenERC20.test.js)
scripts/            - Deployment scripts (deploy.js)
docs/               - Documentation (ARCHITECTURE.md, SECURITY.md, etc.)
apps/               - Backend services (PLACEHOLDER READMEs ONLY)
├── backend/        - API server (placeholder)
├── frontend/       - Web interface (placeholder)  
├── indexer/        - Blockchain indexer (placeholder)
├── agents/         - Scheduled agents (placeholder)
cli/                - Command line tools (placeholder)
infra/docker/       - Docker compose for services (configured but apps don't exist)
```

### Important Contracts
- `TokenERC20.sol` - Upgradeable ERC20 with launch lock (FULLY TESTED)
- `VTV.sol` - Basic ERC20 utility token (NO TESTS)
- `VCHAN.sol` - Governance token (NO TESTS)
- `VPOINT.sol` - Soulbound loyalty points (NO TESTS)
- `NFTMarketplace.sol` - NFT trading with fees (NO TESTS)
- `NFTStaking.sol` - Stake NFTs for ETH rewards (NO TESTS)

## Common Issues and Troubleshooting

### Compilation Warnings (EXPECTED)
These warnings appear during compilation but don't prevent builds:
- Missing SPDX license in NFTMarketplace.sol and NFTStaking.sol
- Variable shadowing in MerkleLib.sol (line 9 and 23)

### Dependency Vulnerabilities (ACCEPTABLE)
- npm audit shows 16 low severity vulnerabilities
- All are in development dependencies (Hardhat toolchain)
- Use `npm audit fix` if needed, but not required for development

### Infrastructure Limitations
- Docker Compose configured but apps/ directories contain only placeholder READMEs
- Cannot run backend services until actual Node.js applications are implemented
- CLI tools are placeholder directories with no executable code

### Git and Artifacts
- Build artifacts in `artifacts/`, `cache/`, `coverage/` are excluded by .gitignore
- Run `npm run clean` before committing to remove generated files
- Gas reports are generated in gasReporterOutput.json (committed)

## Advanced Development

### Adding New Tests
- Follow existing pattern in `test/TokenERC20.test.js`
- Use Mocha/Chai with Hardhat network helpers
- Import: `const { expect } = require("chai");`
- Network helpers: `const { time } = require("@nomicfoundation/hardhat-network-helpers");`

### Security Analysis
- No Slither or formal verification currently integrated
- OpenZeppelin libraries provide security foundations
- Consider adding fuzzing tests for critical contracts
- Review docs/AUDIT_AND_APPRAISAL.md for security recommendations

### Performance Monitoring
- Gas reporting integrated via hardhat-gas-reporter
- Coverage reports generated in coverage/ directory
- Mocha timeout set to 120 seconds in hardhat.config.cjs

## Quick Reference

### Essential Files to Check After Changes
- Always check `test/TokenERC20.test.js` after modifying TokenERC20.sol
- Review `hardhat.config.cjs` if changing compilation settings
- Update `.env` for network configuration changes

### Repository Status Summary
- ✅ Smart contracts: Functional with comprehensive TokenERC20 implementation
- ✅ Testing: Working test suite with coverage reporting
- ✅ Deployment: Scripts work for local and network deployment
- ⚠️ Apps: Placeholder READMEs only, no working backend/frontend code
- ⚠️ CLI: Placeholder directories, no functional tools yet
- ✅ Infrastructure: Docker Compose configured but dependent on app implementation