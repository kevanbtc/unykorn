# Unykorn Token Launch Factory

Unykorn is a cross-chain token launch factory providing Solidity smart contracts for EVM chains, with planned Solana support. The project includes NFT marketplace, staking contracts, utility tokens, and supporting infrastructure for token launches and airdrops.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Setup
- Install dependencies: `npm install` -- takes 55 seconds. NEVER CANCEL. Set timeout to 5+ minutes.
- Copy environment template: `cp .env.template .env` then edit with your RPC URL and deployer private key.

### Build and Test
- Clean artifacts: `npm run clean` -- instantaneous
- Compile contracts: `npm run compile` -- takes 10 seconds. NEVER CANCEL. Set timeout to 2+ minutes.
- Run tests: `npm run test` -- takes 1-3 seconds. Uses parallel execution. NEVER CANCEL. Set timeout to 2+ minutes.
- Coverage analysis: `npm run coverage` -- takes 9 seconds. NEVER CANCEL. Set timeout to 2+ minutes.
- **Full workflow**: `npm run clean && npm run compile && npm run test` -- takes 13 seconds total. NEVER CANCEL. Set timeout to 3+ minutes.

### Important Notes
- **NEVER CANCEL builds or tests** - Wait for ALL commands to complete even if they seem stuck.
- Build warnings about SPDX license identifiers are expected and can be ignored.
- Security warning about variable shadowing in MerkleLib.sol is known and documented.
- The deploy script (scripts/deploy.js) uses older ethers.js syntax and will fail with current versions - this is expected.

## Validation

### Manual Testing Scenarios
After making changes to smart contracts:
1. **Always run the full build and test cycle**:
   ```bash
   npm run clean
   npm run compile
   npm run test
   npm run coverage
   ```

2. **Contract Validation**: The main testable contract is TokenERC20 with launch lock functionality:
   - Test shows token mints 1 billion tokens to deployer
   - Test verifies 7-day transfer lock after deployment
   - Coverage report shows ~80% coverage for TokenERC20

3. **Deploy Test**: Test contract compilation but skip deployment script (it has known issues):
   ```bash
   npx hardhat compile
   # Skip: npx hardhat run scripts/deploy.js --network hardhat (fails with ethers v6)
   ```

### Security and Quality
- Run security audit: `npm audit` (currently shows 16 low severity vulnerabilities - this is expected)
- All contracts use OpenZeppelin libraries for security
- Uses Hardhat toolbox for comprehensive testing suite

## Architecture Overview

### Directory Structure
```
contracts/          - Smart contracts (67 Solidity files)
├── evm/            - EVM-specific contracts (TokenERC20, MemePass721, LiquidityHelper)
├── shared/         - Shared utilities (MerkleLib)
├── *.sol           - Main contracts (VTV, VCHAN, VPOINT, NFTMarketplace, NFTStaking, etc.)
test/               - Test files (currently only TokenERC20.test.js)
scripts/            - Deployment scripts (deploy.js - has known issues)
apps/               - Application placeholders (backend, frontend, indexer, agents)
cli/                - Command line tools (placeholders for EVM and Solana)
docs/               - Documentation (architecture, security, audit reports)
infra/              - Docker infrastructure setup
samples/            - Example CSV files for airdrops
```

### Key Contracts
- **TokenERC20.sol** - Upgradeable ERC20 with permit, roles, launch lock (main working contract)
- **VTV.sol** - Basic ERC20 utility token (1M supply)
- **VCHAN.sol** - Governance token (100K supply)
- **VPOINT.sol** - Soulbound loyalty points
- **NFTMarketplace.sol** - ERC721 marketplace with fees
- **NFTStaking.sol** - Stake NFTs to earn ETH rewards
- **SubscriptionVault.sol** - Monthly subscription payments

### Infrastructure
- Docker Compose setup available: `infra/docker/docker-compose.yml`
- Services: backend, indexer, agents, PostgreSQL, Redis
- All apps are currently placeholders with basic README files

## Development Workflow

1. **Making Contract Changes**:
   - Edit contracts in `contracts/` directory
   - Always run: `npm run clean && npm run compile && npm run test`
   - Check coverage: `npm run coverage`
   - Review coverage report in `coverage/index.html`

2. **Testing Strategy**:
   - Focus on TokenERC20 contract which has working tests
   - Other contracts need test coverage to be added
   - Use `--parallel` flag for faster test execution

3. **Known Issues**:
   - Deploy script fails with current ethers.js version - needs updating
   - Some contracts missing SPDX license identifiers (warnings expected)
   - MerkleLib has variable shadowing warning (documented issue)
   - Apps directories are placeholders only

## Common Commands Reference

### Repository Navigation
```bash
ls                  # Root: README.md, package.json, hardhat.config.cjs, contracts/, test/, etc.
ls contracts/       # All Solidity contracts
ls contracts/evm/   # EVM-specific contracts
ls apps/           # backend, frontend, indexer, agents (placeholders)
ls docs/           # ARCHITECTURE.md, AUDIT_AND_APPRAISAL.md, etc.
```

### Build Information
- **Node.js version**: v20.19.4 (required)
- **npm version**: 10.8.2
- **Package manager**: npm (pnpm workspace configured but npm works fine)
- **Solidity version**: 0.8.24 (locked in hardhat.config.cjs)
- **Test framework**: Mocha with Hardhat toolbox
- **Coverage tool**: solidity-coverage
- **Docker**: Docker Compose v2 available for infrastructure

### File Locations
- Main config: `hardhat.config.cjs`
- Environment: `.env.template` (copy to `.env`)
- Package info: `package.json`
- Git ignore: `.gitignore` (excludes cache/, artifacts/, coverage/)
- Workspace: `pnpm-workspace.yaml`

## Troubleshooting

### Common Issues
1. **Build fails**: Run `npm run clean` first, then `npm install`
2. **Tests fail**: Ensure contracts are compiled first with `npm run compile`  
3. **Deploy script errors**: Known issue with ethers.js v6 compatibility
4. **Missing dependencies**: Run `npm install` with appropriate timeout

### Performance Notes
- Full clean + compile + test cycle: ~13 seconds
- Compilation of 67 contracts: ~10 seconds
- Test suite runs in 1-3 seconds with parallel execution  
- Coverage analysis: ~9 seconds
- npm install: ~55 seconds on first run
- **Always allow extra time in CI/CD environments** - use 2-3x these times for timeouts

## CI/CD Notes
- No GitHub Actions workflows currently exist
- Recommended: Add workflows for compile, test, coverage, and security auditing
- Consider integrating Slither for static analysis (mentioned in docs/SECURITY.md)
- Use longer timeouts in CI (2+ minutes for builds, 5+ minutes for complex operations)