# ⚡ Solana Command Line Tools

[![Solana](https://img.shields.io/badge/Solana-Compatible-purple?logo=solana)](https://solana.com/)
[![Rust](https://img.shields.io/badge/Rust-Lang-orange?logo=rust)](https://www.rust-lang.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](../../README.md)

## 📖 Overview

Solana CLI tools provide command-line utilities for deploying, managing, and interacting with Solana programs, SPL tokens, and cross-chain operations.

## 🎯 Purpose

- **Program Deployment** - Automated Solana program deployment and upgrades
- **Token Management** - SPL token creation, minting, and distribution
- **Airdrop Operations** - Efficient batch token distribution on Solana
- **Cross-Chain Bridge** - Facilitate EVM ↔ Solana token transfers
- **Wallet Management** - Key generation and account management

## 🛠️ Technology Stack

- **Programs:** Rust with Anchor framework
- **CLI Scripts:** TypeScript with @solana/web3.js
- **Token Standard:** SPL Token (fungible and non-fungible)
- **Networks:** Mainnet-beta, Devnet, Testnet, Localnet
- **Deployment:** Solana CLI + Anchor CLI

## 📁 Structure

```
cli/solana/
├── scripts/              # Deployment and utility scripts
│   ├── deploy/           # Program deployment scripts
│   ├── token/            # SPL token management
│   ├── airdrop/          # Token distribution scripts
│   ├── bridge/           # Cross-chain bridge operations
│   └── utils/            # General utility scripts
├── programs/             # Rust program source code
├── config/               # Network and wallet configurations
├── keypairs/             # Generated keypairs (gitignored)
└── templates/            # Program and script templates
```

## 🚀 Available Commands

### Program Deployment Commands
```bash
# Deploy program to devnet
anchor deploy --provider.cluster devnet

# Upgrade existing program
anchor upgrade <PROGRAM_ID> --provider.cluster mainnet-beta

# Initialize program data accounts
ts-node scripts/deploy/initialize-program.ts --network devnet
```

### Token Management Commands
```bash
# Create new SPL token
ts-node scripts/token/create-token.ts --name "MyToken" --symbol "MTK"

# Mint tokens to address
ts-node scripts/token/mint-tokens.ts --token <MINT_PUBKEY> --amount 1000000

# Create token metadata
ts-node scripts/token/create-metadata.ts --token <MINT_PUBKEY>
```

### Airdrop Commands
```bash
# Process airdrop from CSV file
ts-node scripts/airdrop/process-airdrop.ts --file ./samples/solana-airdrop.csv

# Batch transfer SPL tokens
ts-node scripts/airdrop/batch-transfer.ts --token <MINT> --file ./samples/recipients.csv

# Check airdrop status
ts-node scripts/airdrop/check-status.ts --signature <TX_SIGNATURE>
```

### Bridge Commands
```bash
# Bridge tokens from EVM to Solana
ts-node scripts/bridge/evm-to-solana.ts --amount 1000 --recipient <SOLANA_ADDRESS>

# Bridge tokens from Solana to EVM
ts-node scripts/bridge/solana-to-evm.ts --amount 1000 --recipient <EVM_ADDRESS>

# Check bridge status
ts-node scripts/bridge/status.ts --bridge-tx <SIGNATURE>
```

## 🌐 Supported Networks

### Solana Networks
- **Mainnet-beta** - Production network with real SOL
- **Devnet** - Development network with free SOL
- **Testnet** - Testing network for final validation
- **Localnet** - Local validator for development

### Network Configuration
```typescript
// Network endpoints
const networks = {
  'mainnet-beta': 'https://api.mainnet-beta.solana.com',
  'devnet': 'https://api.devnet.solana.com',
  'testnet': 'https://api.testnet.solana.com',
  'localnet': 'http://localhost:8899'
};
```

## 🔧 Configuration

### Environment Setup
```bash
# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/v1.16.0/install)"

# Install Anchor
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install latest
avm use latest

# Generate keypair
solana-keygen new --outfile ~/.config/solana/id.json
```

### Environment Variables
```bash
# Network Configuration
SOLANA_NETWORK=devnet
SOLANA_RPC_URL=https://api.devnet.solana.com

# Wallet Configuration
SOLANA_KEYPAIR_PATH=~/.config/solana/id.json
PROGRAM_KEYPAIR_PATH=./keypairs/program-keypair.json

# Token Configuration
TOKEN_METADATA_PROGRAM=metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s
TOKEN_PROGRAM=TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
```

## 🪙 SPL Token Operations

### Token Creation
```typescript
// Create new SPL token mint
const mint = await createMint(
  connection,
  payer,
  mintAuthority,
  freezeAuthority,
  decimals
);

// Create token metadata
await createMetadataAccountV3(
  connection,
  payer,
  mint,
  mintAuthority,
  payer.publicKey,
  {
    name: tokenName,
    symbol: tokenSymbol,
    uri: metadataUri,
    sellerFeeBasisPoints: 0,
    creators: null,
    collection: null,
    uses: null
  }
);
```

### Batch Operations
```typescript
// Efficient batch token transfers
async function batchTransfer(recipients: Recipient[]) {
  const transaction = new Transaction();
  
  for (const recipient of recipients) {
    const instruction = createTransferInstruction(
      sourceAccount,
      recipient.tokenAccount,
      payer.publicKey,
      recipient.amount
    );
    transaction.add(instruction);
  }
  
  return await sendAndConfirmTransaction(connection, transaction, [payer]);
}
```

## 🌉 Cross-Chain Bridge

### Bridge Architecture
```
EVM Network ←→ Bridge Program ←→ Solana Network
     ↓              ↓              ↓
  Lock Tokens → Mint Wrapped → Transfer SPL
     ↑              ↑              ↑
 Unlock Tokens ← Burn Wrapped ← Transfer Back
```

### Bridge Operations
```typescript
// Lock tokens on EVM and mint on Solana
async function bridgeToSolana(evmTxHash: string, recipient: PublicKey) {
  // Verify EVM lock transaction
  const verified = await verifyEvmLock(evmTxHash);
  
  if (verified) {
    // Mint wrapped tokens on Solana
    await mintWrappedTokens(recipient, verified.amount);
  }
}

// Burn tokens on Solana and unlock on EVM
async function bridgeToEvm(burnSignature: string, evmRecipient: string) {
  // Verify Solana burn transaction
  const verified = await verifySolanaBurn(burnSignature);
  
  if (verified) {
    // Unlock tokens on EVM
    await unlockEvmTokens(evmRecipient, verified.amount);
  }
}
```

## 🔍 Program Verification

### Program Verification
```bash
# Verify program build is reproducible
anchor verify <PROGRAM_ID>

# Check program upgrade authority
solana program show <PROGRAM_ID>

# Audit program accounts
ts-node scripts/utils/audit-program.ts --program <PROGRAM_ID>
```

## 📊 Performance Optimization

### Transaction Optimization
```typescript
// Use versioned transactions for efficiency
const transaction = new VersionedTransaction(
  new TransactionMessage({
    payerKey: payer.publicKey,
    recentBlockhash: blockhash,
    instructions: instructions
  }).compileToV0Message()
);

// Priority fees for faster confirmation
const priorityFeeInstruction = ComputeBudgetProgram.setComputeUnitPrice({
  microLamports: 1000
});
```

### Batch Processing
- **Parallel Processing** - Multiple transactions simultaneously
- **Transaction Chunking** - Split large operations into smaller batches
- **Priority Fees** - Ensure fast confirmation during high congestion

## 🧪 Testing & Validation

### Local Testing
```bash
# Start local validator
solana-test-validator

# Deploy to local validator
anchor deploy --provider.cluster localnet

# Run integration tests
anchor test
```

### Program Testing
```rust
#[tokio::test]
async fn test_token_transfer() {
    let program = client.program(program_id);
    
    // Test token transfer functionality
    let result = program
        .request()
        .accounts(accounts)
        .args(instruction_data)
        .send()
        .await;
        
    assert!(result.is_ok());
}
```

## 📚 Related Documentation

- [EVM CLI Tools](../evm/README.md)
- [Solana Programs](../../contracts/solana/README.md)
- [Bridge Documentation](../../docs/BRIDGE.md)
