# 🏗️ System Architecture

[![Architecture](https://img.shields.io/badge/Architecture-Microservices-blue)](https://microservices.io/)
[![Status](https://img.shields.io/badge/Status-Active%20Development-green)](../README.md)

## 📖 Overview

Unykorn follows a modular microservices architecture designed for scalability, maintainability, and cross-chain compatibility. The system separates concerns into distinct layers with clear interfaces and responsibilities.

## 🎯 Design Principles

- **🔧 Modularity** - Independent, loosely-coupled components
- **🌐 Cross-Chain** - Multi-blockchain support with unified interfaces  
- **📈 Scalability** - Horizontal scaling with containerized services
- **🔒 Security** - Defense in depth with multiple security layers
- **⚡ Performance** - Optimized for high-throughput operations

## 🏗️ System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    🌐 Frontend Layer                        │
├─────────────────────────────────────────────────────────────┤
│  Next.js App   │  Marketing Site  │  Admin Dashboard       │
│  (Port 3000)   │  (Static)        │  (Port 3001)           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    🔌 API Gateway Layer                     │
├─────────────────────────────────────────────────────────────┤
│          Load Balancer + Rate Limiting + Auth              │
│                    (Port 8080)                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   📊 Application Layer                      │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Backend API   │    Indexer      │      Agents             │
│  (Port 8000)    │  (Port 8001)    │   (Background)          │
│                 │                 │                         │
│ • Metadata      │ • Event Monitor │ • Airdrop Queue        │
│ • Airdrop API   │ • Data Sync     │ • Payout Processor     │
│ • User Auth     │ • Analytics     │ • Monitor/Alerts       │
└─────────────────┴─────────────────┴─────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    💾 Data Layer                            │
├─────────────────┬─────────────────┬─────────────────────────┤
│   PostgreSQL    │     Redis       │       IPFS              │
│  (Port 5432)    │  (Port 6379)    │   (Distributed)         │
│                 │                 │                         │
│ • User Data     │ • Cache         │ • Metadata Storage     │
│ • Transactions  │ • Sessions      │ • Asset Storage        │
│ • Analytics     │ • Job Queue     │ • Backup Storage       │
└─────────────────┴─────────────────┴─────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  ⛓️ Blockchain Layer                        │
├─────────────────┬─────────────────┬─────────────────────────┤
│   EVM Networks  │  Solana Network │    Cross-Chain          │
│                 │                 │                         │
│ • Ethereum      │ • Mainnet-beta  │ • Bridge Contracts     │
│ • Polygon       │ • Devnet        │ • Relay Services       │
│ • BSC/Arbitrum  │ • Testnet       │ • Oracle Integration   │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 📁 Repository Structure

```
unykorn/
├── 📱 apps/                    # Application layer services
│   ├── frontend/               # User interface (Next.js)
│   │   ├── src/app/           # App router pages
│   │   ├── components/        # Reusable UI components
│   │   └── lib/               # Client-side utilities
│   ├── backend/               # API server (Express.js)
│   │   ├── src/routes/        # REST API endpoints
│   │   ├── services/          # Business logic
│   │   └── middleware/        # Request processing
│   ├── indexer/               # Blockchain data indexer
│   │   ├── src/indexers/      # Chain-specific indexers
│   │   ├── processors/        # Event processing
│   │   └── models/            # Data models
│   └── agents/                # Background services
│       ├── src/agents/        # Individual agents
│       └── jobs/              # Job definitions
├── 📜 contracts/              # Smart contracts
│   ├── *.sol                  # Core EVM contracts
│   ├── evm/                   # EVM utilities
│   ├── solana/                # Solana programs
│   └── shared/                # Cross-chain libraries
├── ⚙️ cli/                    # Command line tools
│   ├── evm/                   # EVM deployment tools
│   └── solana/                # Solana program tools
├── 📚 docs/                   # Documentation
├── 🐳 infra/                  # Infrastructure code
├── 📊 samples/                # Example data files
├── 🧪 scripts/               # Utility scripts
└── 🧪 test/                   # Test suites
```

The repository is designed as a **monorepo** using **pnpm workspaces** for efficient dependency management and cross-package development.

## 🔄 Data Flow Architecture

### 1. User Interaction Flow
```
User → Frontend → API Gateway → Backend API → Database
                                     ↓
                              Blockchain Interaction
```

### 2. Blockchain Event Flow
```
Blockchain → Indexer → Database → Backend API → Frontend (Real-time)
                  ↓
              Analytics Agents
```

### 3. Background Processing Flow
```
Scheduled Trigger → Agent → Job Queue → Processing → Database → Notifications
```

## 🌐 Network Architecture

### Frontend Deployment
- **CDN Distribution** - Global content delivery
- **Static Asset Optimization** - Compressed and cached assets
- **Progressive Web App** - Offline capabilities and caching

### Backend Services
- **Load Balancing** - Traffic distribution across instances
- **Auto Scaling** - Dynamic scaling based on demand
- **Circuit Breakers** - Fault tolerance and resilience

### Database Architecture
- **Read Replicas** - Improved read performance
- **Connection Pooling** - Efficient database connections
- **Backup Strategy** - Automated backups and point-in-time recovery

## 🔐 Security Architecture

### Application Security
```
Internet → WAF → Load Balancer → API Gateway → Services
   ↓         ↓         ↓            ↓           ↓
  DDoS    Filter    SSL Term.   Rate Limit   JWT Auth
```

### Data Security
- **Encryption at Rest** - Database and file encryption
- **Encryption in Transit** - TLS 1.3 for all communications
- **Key Management** - Hardware security modules (HSM)
- **Access Control** - Role-based permissions (RBAC)

### Blockchain Security
- **Multi-Signature** - Required for critical operations
- **Timelock** - Delayed execution for upgrades
- **Audit Trails** - Complete transaction logging
- **Formal Verification** - Mathematical proof of correctness

## 📊 Performance Architecture

### Caching Strategy
```
Browser Cache → CDN → Redis Cache → Database
     (1h)        (24h)    (15m)      (Source)
```

### Database Optimization
- **Indexing Strategy** - Optimized query performance
- **Partitioning** - Time-based table partitioning
- **Query Optimization** - Efficient query patterns
- **Connection Pooling** - Minimized connection overhead

### Monitoring & Observability
- **Application Metrics** - Performance monitoring
- **Error Tracking** - Centralized error reporting
- **Log Aggregation** - Structured logging across services
- **Alerting** - Proactive issue detection

## 🚀 Deployment Architecture

### Container Strategy
```dockerfile
# Multi-stage builds for optimization
FROM node:18-alpine AS builder
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
COPY --from=builder /app .
EXPOSE 8000
CMD ["npm", "start"]
```

### Orchestration
- **Docker Compose** - Local development environment
- **Kubernetes** - Production container orchestration
- **Helm Charts** - Kubernetes application management
- **CI/CD Pipelines** - Automated testing and deployment

## 🔗 Integration Points

### External Services
- **RPC Providers** - Blockchain network access (Alchemy, Infura)
- **IPFS Gateways** - Decentralized storage (Pinata, Web3.Storage)
- **Analytics** - Business intelligence (Mixpanel, Amplitude)
- **Monitoring** - Infrastructure monitoring (Datadog, New Relic)

### Cross-Chain Communication
- **Bridge Protocols** - Token transfer between chains
- **Oracle Networks** - Off-chain data feeds (Chainlink)
- **Message Passing** - Cross-chain communication protocols

## 📈 Scalability Considerations

### Horizontal Scaling
- **Stateless Services** - Easy horizontal scaling
- **Database Sharding** - Distribute data across instances
- **Queue-Based Processing** - Asynchronous task handling
- **Event-Driven Architecture** - Loose coupling between services

### Performance Optimization
- **Connection Pooling** - Database and external service connections
- **Batch Processing** - Efficient bulk operations
- **Lazy Loading** - On-demand resource loading
- **CDN Distribution** - Global content delivery

## 🛠️ Technology Stack Summary

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Next.js 14, TypeScript, Tailwind | User interface and experience |
| **API Gateway** | nginx, Kong | Request routing and rate limiting |
| **Backend** | Node.js, Express, TypeScript | Business logic and API services |
| **Database** | PostgreSQL, Redis | Data persistence and caching |
| **Blockchain** | Solidity, Rust, Web3 libraries | Smart contracts and interactions |
| **Infrastructure** | Docker, Kubernetes, CI/CD | Deployment and orchestration |
| **Monitoring** | Prometheus, Grafana, ELK | Observability and alerting |

## 📚 Related Documentation

- [Security Architecture](SECURITY.md)
- [Deployment Guide](DEPLOYMENT.md)
- [API Documentation](API.md)
- [Database Schema](DATABASE.md)
