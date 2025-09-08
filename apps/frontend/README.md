# 🌐 Frontend Application

[![Next.js](https://img.shields.io/badge/Next.js-14-black?logo=next.js)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](../README.md)

## 📖 Overview

The Unykorn frontend is a modern Next.js 14 application providing user-facing interfaces for token launches, claims, and community engagement. Built with TypeScript, Tailwind CSS, and Web3 integration.

## 🎯 Purpose

- **Marketing Site** - Landing pages for token launches and project promotion
- **Claim Interface** - User-friendly token claiming and airdrop management
- **Dashboard** - Portfolio tracking and analytics for users
- **Community Hub** - Social features and engagement tools

## 🛠️ Technology Stack

- **Framework:** Next.js 14 with App Router
- **Language:** TypeScript
- **Styling:** Tailwind CSS + shadcn/ui components
- **Web3:** Wagmi + RainbowKit for wallet connections
- **State Management:** Zustand
- **Forms:** React Hook Form + Zod validation
- **Analytics:** Built-in performance monitoring

## 📁 Planned Structure

```
apps/frontend/
├── src/
│   ├── app/              # Next.js 14 app router pages
│   ├── components/       # Reusable UI components
│   ├── lib/              # Utilities and configurations
│   ├── hooks/            # Custom React hooks
│   └── types/            # TypeScript type definitions
├── public/               # Static assets
├── styles/               # Global styles and themes
└── __tests__/            # Test suites
```

## 🚀 Features (Planned)

### Phase 1: Core Interface
- [ ] Landing page with project overview
- [ ] Wallet connection and authentication
- [ ] Basic token claim interface
- [ ] Responsive mobile design

### Phase 2: Enhanced UX
- [ ] Interactive dashboards
- [ ] Multi-chain support
- [ ] Advanced claim flows
- [ ] Social sharing integration

### Phase 3: Community Features
- [ ] User profiles and achievements
- [ ] Community leaderboards
- [ ] Referral tracking
- [ ] Analytics and insights

## 🔧 Development

### Prerequisites
- Node.js 18+
- npm or yarn

### Getting Started
```bash
# Navigate to frontend directory
cd apps/frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Environment Variables
```bash
# Copy environment template
cp .env.template .env.local

# Configure required variables:
# NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=
# NEXT_PUBLIC_ALCHEMY_API_KEY=
# NEXT_PUBLIC_CHAIN_ID=
```

## 🎨 Design System

The frontend follows a modern, accessible design system with:

- **Glassmorphism Effects** - Frosted glass UI elements
- **3D Interactions** - Subtle depth and hover effects
- **High Contrast** - WCAG AA compliant color schemes
- **Responsive Design** - Mobile-first approach
- **Dark/Light Mode** - System preference detection

## 🔗 Integration Points

- **Smart Contracts** - Direct blockchain interaction via Wagmi
- **Backend API** - RESTful endpoints for metadata and proofs
- **Indexer** - Real-time blockchain data consumption
- **CLI Tools** - Administrative interface integration

## 📈 Performance Goals

- **Lighthouse Score:** >90 across all metrics
- **Core Web Vitals:** Green across all measures
- **Bundle Size:** <500KB initial load
- **Time to Interactive:** <3 seconds

## 🧪 Testing Strategy

- **Unit Tests** - Component and utility testing
- **Integration Tests** - API and wallet interaction flows
- **E2E Tests** - Complete user journey validation
- **Accessibility Tests** - WCAG compliance verification

## 📚 Related Documentation

- [Backend API](../backend/README.md)
- [Smart Contracts](../../contracts/README.md)
- [Development Guidelines](../../docs/DEVELOPMENT.md)
