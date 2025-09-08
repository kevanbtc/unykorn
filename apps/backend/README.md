# 🔌 Backend API Server

[![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.x-lightgrey?logo=express)](https://expressjs.com/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](../README.md)

## 📖 Overview

The Unykorn backend provides a robust API server handling metadata management, airdrop proof generation, influencer redirect tracking, and blockchain data aggregation.

## 🎯 Purpose

- **Metadata API** - Serve token and NFT metadata with IPFS integration
- **Airdrop Proofs** - Generate and validate Merkle proofs for token claims
- **Influencer Tracking** - Handle referral links and commission calculations
- **Data Aggregation** - Process and serve blockchain data from the indexer
- **Authentication** - Manage user sessions and wallet-based auth

## 🛠️ Technology Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js with TypeScript
- **Database:** PostgreSQL with Prisma ORM
- **Authentication:** JWT + Wallet signatures
- **Storage:** IPFS for metadata, Redis for caching
- **Validation:** Zod schemas
- **Testing:** Jest + Supertest

## 📁 Planned Structure

```
apps/backend/
├── src/
│   ├── routes/           # API route handlers
│   │   ├── auth/         # Authentication endpoints
│   │   ├── metadata/     # Token/NFT metadata
│   │   ├── airdrops/     # Airdrop management
│   │   ├── referrals/    # Influencer tracking
│   │   └── analytics/    # Data and metrics
│   ├── middleware/       # Express middleware
│   ├── services/         # Business logic
│   ├── models/           # Database models
│   ├── utils/            # Utilities and helpers
│   └── types/            # TypeScript definitions
├── prisma/               # Database schema and migrations
├── tests/                # Test suites
└── scripts/              # Utility scripts
```

## 🚀 API Endpoints (Planned)

### Authentication
```
POST /auth/login              # Wallet-based login
POST /auth/verify             # Signature verification
GET  /auth/profile            # User profile data
```

### Metadata
```
GET  /metadata/tokens/:id     # Token metadata
GET  /metadata/nfts/:id       # NFT metadata
POST /metadata/upload         # Upload to IPFS
```

### Airdrops
```
GET  /airdrops/eligibility    # Check claim eligibility
POST /airdrops/claim          # Generate claim proof
GET  /airdrops/merkle/:root   # Merkle tree data
```

### Referrals
```
POST /referrals/track         # Track referral events
GET  /referrals/stats/:user   # User referral statistics
POST /referrals/payout        # Process commission payouts
```

### Analytics
```
GET  /analytics/overview      # Platform metrics
GET  /analytics/tokens/:id    # Token-specific data
GET  /analytics/users/:addr   # User analytics
```

## 🔧 Development

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Redis (optional, for caching)

### Getting Started
```bash
# Navigate to backend directory
cd apps/backend

# Install dependencies
npm install

# Set up database
npm run db:setup

# Start development server
npm run dev

# Run tests
npm run test
```

### Environment Variables
```bash
# Copy environment template
cp .env.template .env

# Configure required variables:
# DATABASE_URL=postgresql://user:pass@localhost:5432/unykorn
# JWT_SECRET=your-jwt-secret
# IPFS_API_URL=https://api.pinata.cloud
# REDIS_URL=redis://localhost:6379
```

## 📊 Database Schema

### Core Tables
- **users** - User profiles and wallet addresses
- **tokens** - Token metadata and configurations
- **airdrops** - Airdrop campaigns and eligibility
- **referrals** - Influencer tracking and commissions
- **claims** - Token claim history and proofs

### Relationships
```sql
users 1:M referrals
tokens 1:M airdrops
airdrops 1:M claims
users 1:M claims
```

## 🔐 Security Features

- **Rate Limiting** - API endpoint protection
- **Input Validation** - Zod schema validation
- **SQL Injection Prevention** - Parameterized queries via Prisma
- **CORS Configuration** - Controlled cross-origin access
- **Authentication** - JWT + wallet signature verification

## 📈 Performance Optimizations

- **Database Indexing** - Optimized query performance
- **Redis Caching** - Frequently accessed data caching
- **Connection Pooling** - Efficient database connections
- **Compression** - Response compression middleware
- **Monitoring** - Performance metrics and alerting

## 🧪 Testing Strategy

- **Unit Tests** - Service and utility function testing
- **Integration Tests** - Database and external API testing
- **API Tests** - Complete endpoint validation
- **Load Tests** - Performance under stress

## 🔗 Integration Points

- **Frontend** - RESTful API consumption
- **Indexer** - Real-time blockchain data sync
- **Smart Contracts** - On-chain data verification
- **IPFS** - Decentralized metadata storage

## 📚 Related Documentation

- [Frontend Application](../frontend/README.md)
- [Database Indexer](../indexer/README.md)
- [API Documentation](../../docs/API.md)
