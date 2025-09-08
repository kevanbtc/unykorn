# 📊 Blockchain Event Indexer

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue?logo=postgresql)](https://postgresql.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](../README.md)

## 📖 Overview

The Unykorn indexer is a high-performance blockchain event monitoring system that tracks on-chain activities across multiple networks and stores structured data in PostgreSQL for real-time access.

## 🎯 Purpose

- **Event Monitoring** - Real-time tracking of smart contract events
- **Multi-Chain Support** - Index data from EVM and Solana networks
- **Data Normalization** - Structure blockchain data for efficient querying
- **Historical Analysis** - Maintain complete event history for analytics
- **Performance Optimization** - Fast data retrieval for frontend and APIs

## 🛠️ Technology Stack

- **Runtime:** Node.js 18+ with TypeScript
- **Database:** PostgreSQL 14+ with advanced indexing
- **Blockchain Clients:** Ethers.js (EVM), @solana/web3.js (Solana)
- **Queue System:** Bull for job processing
- **Monitoring:** Prometheus metrics
- **ORM:** Prisma for type-safe database operations

## 📁 Planned Structure

```
apps/indexer/
├── src/
│   ├── indexers/         # Chain-specific indexers
│   │   ├── evm/          # EVM network indexer
│   │   └── solana/       # Solana network indexer
│   ├── processors/       # Event processing logic
│   ├── models/           # Database models and schemas
│   ├── services/         # Business logic services
│   ├── utils/            # Utilities and helpers
│   └── types/            # TypeScript definitions
├── migrations/           # Database migrations
├── config/               # Network and indexer configurations
└── scripts/              # Utility and deployment scripts
```

## 🔄 Indexing Strategy

### EVM Networks
```typescript
// Indexed Events
- Transfer events (ERC-20, ERC-721)
- Marketplace transactions
- Staking operations
- Airdrop claims
- Referral registrations
```

### Solana Programs
```typescript
// Indexed Instructions
- SPL token transfers
- Program interactions
- Account state changes
- Transaction metadata
```

### Data Flow
```
Blockchain → Event Detection → Processing Queue → Database → API Access
```

## 📊 Database Schema

### Core Tables

#### Events Table
```sql
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  chain VARCHAR(20) NOT NULL,
  block_number BIGINT NOT NULL,
  transaction_hash VARCHAR(66) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  contract_address VARCHAR(44) NOT NULL,
  data JSONB NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  processed_at TIMESTAMP DEFAULT NOW()
);
```

#### Tokens Table
```sql
CREATE TABLE tokens (
  id BIGSERIAL PRIMARY KEY,
  chain VARCHAR(20) NOT NULL,
  address VARCHAR(44) NOT NULL UNIQUE,
  symbol VARCHAR(20),
  name VARCHAR(100),
  decimals INTEGER,
  total_supply NUMERIC(78, 0),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### Transfers Table
```sql
CREATE TABLE transfers (
  id BIGSERIAL PRIMARY KEY,
  chain VARCHAR(20) NOT NULL,
  token_address VARCHAR(44) NOT NULL,
  from_address VARCHAR(44) NOT NULL,
  to_address VARCHAR(44) NOT NULL,
  amount NUMERIC(78, 0) NOT NULL,
  block_number BIGINT NOT NULL,
  transaction_hash VARCHAR(66) NOT NULL,
  timestamp TIMESTAMP NOT NULL
);
```

## 🚀 Features (Planned)

### Phase 1: Core Indexing
- [ ] EVM event monitoring (Ethereum, Polygon, BSC)
- [ ] Basic token transfer tracking
- [ ] Database persistence with proper indexing
- [ ] Error handling and retry mechanisms

### Phase 2: Advanced Features
- [ ] Solana program monitoring
- [ ] Complex event processing (marketplace, staking)
- [ ] Real-time notifications
- [ ] Historical data backfilling

### Phase 3: Analytics & Optimization
- [ ] Advanced analytics queries
- [ ] Data aggregation and caching
- [ ] Performance monitoring
- [ ] Automated scaling

## 🔧 Development

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Redis (for queue management)

### Getting Started
```bash
# Navigate to indexer directory
cd apps/indexer

# Install dependencies
npm install

# Set up database
npm run db:setup

# Start indexer
npm run start

# Monitor logs
npm run logs
```

### Environment Variables
```bash
# Copy environment template
cp .env.template .env

# Configure required variables:
# DATABASE_URL=postgresql://user:pass@localhost:5432/unykorn_indexer
# ETHEREUM_RPC_URL=https://eth-mainnet.alchemyapi.io/v2/your-key
# POLYGON_RPC_URL=https://polygon-mainnet.alchemyapi.io/v2/your-key
# SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
# REDIS_URL=redis://localhost:6379
```

## 📈 Performance Metrics

### Target Performance
- **Event Processing:** >1000 events/second
- **Database Writes:** <100ms average latency
- **Query Response:** <50ms for standard queries
- **Uptime:** >99.9% availability

### Monitoring
- Real-time processing metrics
- Database performance analytics
- Error rate tracking
- Memory and CPU utilization

## 🔍 Query Optimization

### Indexing Strategy
```sql
-- Block number indexes for range queries
CREATE INDEX idx_events_block_number ON events(block_number);
CREATE INDEX idx_transfers_block_number ON transfers(block_number);

-- Address indexes for user queries
CREATE INDEX idx_transfers_from_address ON transfers(from_address);
CREATE INDEX idx_transfers_to_address ON transfers(to_address);

-- Composite indexes for common query patterns
CREATE INDEX idx_events_chain_type ON events(chain, event_type);
CREATE INDEX idx_transfers_token_timestamp ON transfers(token_address, timestamp);
```

### Partitioning
```sql
-- Partition events table by month for better performance
CREATE TABLE events_2024_01 PARTITION OF events
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

## 🧪 Testing Strategy

- **Unit Tests** - Event processing logic
- **Integration Tests** - Database operations
- **End-to-End Tests** - Complete indexing flows
- **Performance Tests** - Load testing with high event volumes

## 🔗 Integration Points

- **Backend API** - Provides indexed data via REST endpoints
- **Frontend** - Real-time updates via WebSocket connections
- **Smart Contracts** - Monitors deployed contract events
- **Analytics** - Feeds business intelligence dashboards

## 📚 Related Documentation

- [Backend API](../backend/README.md)
- [Database Schema](../../docs/DATABASE.md)
- [Monitoring Guide](../../docs/MONITORING.md)
