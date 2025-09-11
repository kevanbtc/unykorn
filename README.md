# Unykorn - Web3 Onboarding Platform

**Turn time & intros into value.** A production-ready Web3 onboarding platform that makes cryptocurrency accessible to everyone through beautiful design and seamless user experience.

## 🌟 Overview

Unykorn is a complete Web3 ecosystem featuring smart contracts, a stunning frontend application, and comprehensive tooling for launching cross-chain tokens with airdrop and marketing capabilities.

### ✨ Key Features

- **🎨 Glassmorphism Design**: Beautiful frosted glass UI with smooth animations
- **🔗 Multi-Chain Support**: Ethereum, Polygon, Optimism, Arbitrum, Base, Sepolia
- **💼 Wallet Integration**: RainbowKit with email/phone fallbacks for non-crypto users
- **📱 Mobile-First**: Responsive design optimized for all screen sizes
- **⚡ Performance**: Lighthouse scores ≥90 across all metrics
- **♿ Accessible**: WCAG AA compliant with full keyboard navigation

### 🏗 Architecture

```
apps/        - frontend, backend, indexer and scheduled agents
contracts/   - smart contracts for EVM and Solana
cli/         - command line tools for deployment and airdrops
infra/       - docker-compose and CI stubs
samples/     - example CSV files for airdrops and allocations
docs/        - comprehensive documentation
```

## 🚀 Quick Start

### Frontend Application

The main user-facing application is a Next.js 14 app with TypeScript and Tailwind CSS:

```bash
cd apps/frontend
npm install
cp .env.example .env.local
# Add your WalletConnect Project ID to .env.local
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see the application.

### Smart Contracts

Smart contract development with Hardhat:

```bash
npm install
npx hardhat compile
npx hardhat test
```

Copy `.env.template` to `.env` and configure your network settings.

## 📱 Application Features

### Core Pages
- **Landing Page**: Hero section with clear value propositions
- **Join Page**: One-tap onboarding with QR code support
- **Connector Page**: Create and share intro links
- **Merchant Page**: Generate payment links with QR codes
- **Dashboard**: Activity tracking and wallet management

### Web3 Capabilities
- **Wallet Connect**: Multiple wallet support with fallback authentication
- **QR Generation**: Automatic QR codes for all shareable links
- **State Management**: Persistent state with Zustand
- **Multi-Chain**: Support for all major EVM chains

## 🔧 Smart Contracts

### Token Suite
- `VTV.sol` – ERC-20 utility token with launch locks
- `VCHAN.sol` – Governance token with voting mechanisms
- `VPOINT.sol` – Soulbound loyalty points (non-transferable)
- `TokenERC20.sol` – Upgradeable ERC-20 with UUPS proxy pattern

### NFT & Marketplace
- `MemePass721.sol` – NFT passes with optional soulbound mode
- `NFTMarketplace.sol` – List and purchase ERC-721 tokens
- `NFTStaking.sol` – Stake NFTs to earn ETH rewards

### DeFi & Payments
- `SubscriptionVault.sol` – Monthly subscription payments
- `AffiliateRouter.sol` – Referral commission tracking
- `LiquidityHelper.sol` – DEX integration utilities

## 🌐 Deployment

### Netlify (Recommended)

The frontend is optimized for Netlify deployment:

1. Connect your GitHub repository to Netlify
2. Set build command: `cd apps/frontend && npm run build`
3. Set publish directory: `apps/frontend/.next`
4. Add environment variables
5. Deploy!

The included `netlify.toml` handles all configuration automatically.

### Environment Variables

Required for wallet functionality:
```env
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id_here
```

Get your project ID from [WalletConnect Cloud](https://cloud.walletconnect.com/).

## 📚 Documentation

- **[Architecture](docs/ARCHITECTURE.md)** - System design and component overview
- **[Security](docs/AUDIT_AND_APPRAISAL.md)** - Security audit and compliance
- **[Tokenomics](docs/TOKENOMICS.md)** - Token distribution and economics
- **[Frontend README](apps/frontend/README.md)** - Detailed frontend documentation

## 🔒 Security & Audit

See the [Audit and Appraisal Report](docs/AUDIT_AND_APPRAISAL.md) for comprehensive security findings, compliance guidance, and value assessment.

**Rating:** B (moderate risk) with recommendations for enhanced automated testing and multi-signature governance.

## 🛠 Development

### Prerequisites
- Node.js 18+
- npm or yarn
- Git

### Setup
```bash
# Clone repository
git clone https://github.com/kevanbtc/unykorn.git
cd unykorn

# Install dependencies
npm install

# Start frontend
cd apps/frontend
npm run dev

# In another terminal, compile contracts
cd ../..
npx hardhat compile
npx hardhat test
```

### Project Structure
- **Frontend**: Next.js 14 with TypeScript, Tailwind CSS, and shadcn/ui
- **Smart Contracts**: Hardhat with OpenZeppelin libraries
- **State Management**: Zustand with persistence
- **Web3**: RainbowKit + Wagmi for wallet connectivity
- **Styling**: Glassmorphism design system with CSS variables

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines and open an issue or pull request.

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for the future of Web3 onboarding**

*Making cryptocurrency accessible to everyone through beautiful design and seamless user experience.*
