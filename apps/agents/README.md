# 🤖 Automated Agents & Tasks

[![Node.js](https://img.shields.io/badge/Node.js-18+-green?logo=node.js)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](../README.md)

## 📖 Overview

The Unykorn agents system provides automated background services for scheduled tasks, monitoring, maintenance, and business process automation across the entire platform.

## 🎯 Purpose

- **Scheduled Tasks** - Automated recurring operations and maintenance
- **Monitoring & Alerts** - System health monitoring and notification systems
- **Data Processing** - Background data analysis and report generation
- **Maintenance** - Automated cleanup, optimization, and system maintenance
- **Business Automation** - Automated workflows for airdrops, payouts, and operations

## 🛠️ Technology Stack

- **Runtime:** Node.js 18+ with TypeScript
- **Scheduler:** Cron jobs with node-cron
- **Queue System:** Bull Redis queues for job processing
- **Monitoring:** Custom health checks and alerting
- **Database:** Shared PostgreSQL with other services
- **Notifications:** Email, Discord, Slack integrations

## 📁 Planned Structure

```
apps/agents/
├── src/
│   ├── agents/           # Individual agent implementations
│   │   ├── airdrop/      # Airdrop distribution agent
│   │   ├── payout/       # Commission payout agent
│   │   ├── monitor/      # System monitoring agent
│   │   ├── cleanup/      # Data cleanup agent
│   │   └── reports/      # Analytics reporting agent
│   ├── services/         # Shared services and utilities
│   ├── jobs/             # Job definitions and processors
│   ├── utils/            # Helper functions and utilities
│   └── types/            # TypeScript definitions
├── config/               # Agent configurations
├── schedules/            # Cron schedule definitions
└── scripts/              # Deployment and utility scripts
```

## 🤖 Agent Types

### 💰 Airdrop Agent
**Purpose:** Automated airdrop distribution and management
```typescript
Features:
- Scheduled airdrop releases
- Eligibility verification
- Batch transaction processing
- Distribution reporting
- Error handling and retry logic
```

### 💸 Payout Agent
**Purpose:** Automated commission and reward processing
```typescript
Features:
- Referral commission calculations
- Staking reward distributions
- Gas optimization for batch payouts
- Transaction monitoring
- Payout reconciliation
```

### 📊 Monitoring Agent
**Purpose:** System health and performance monitoring
```typescript
Features:
- Service uptime monitoring
- Database performance tracking
- Blockchain connectivity checks
- Error rate analysis
- Alert generation and routing
```

### 🧹 Cleanup Agent
**Purpose:** Data maintenance and optimization
```typescript
Features:
- Old log file cleanup
- Database maintenance tasks
- Cache invalidation
- Orphaned data removal
- Storage optimization
```

### 📈 Reports Agent
**Purpose:** Automated analytics and reporting
```typescript
Features:
- Daily/weekly/monthly reports
- KPI calculation and tracking
- User engagement analytics
- Financial reporting
- Performance dashboards
```

## ⏰ Scheduling System

### Cron Schedule Examples
```javascript
// Daily maintenance at 2 AM UTC
const dailyMaintenance = '0 2 * * *';

// Hourly monitoring checks
const hourlyMonitoring = '0 * * * *';

// Weekly reports on Mondays at 9 AM UTC
const weeklyReports = '0 9 * * 1';

// Airdrop distributions every 5 minutes during active periods
const airdropDistribution = '*/5 * * * *';
```

### Job Queue Management
```typescript
// High priority jobs (alerts, critical operations)
const highPriorityQueue = new Queue('high-priority', {
  defaultJobOptions: {
    priority: 10,
    attempts: 3,
    backoff: 'exponential'
  }
});

// Normal priority jobs (routine tasks)
const normalPriorityQueue = new Queue('normal-priority', {
  defaultJobOptions: {
    priority: 5,
    attempts: 2,
    delay: 1000
  }
});
```

## 🚀 Features (Planned)

### Phase 1: Core Agents
- [ ] Basic monitoring agent with health checks
- [ ] Simple cleanup agent for log rotation
- [ ] Manual job triggering interface
- [ ] Basic error handling and logging

### Phase 2: Business Automation
- [ ] Airdrop distribution automation
- [ ] Commission payout processing
- [ ] Analytics report generation
- [ ] Alert system integration

### Phase 3: Advanced Features
- [ ] ML-based anomaly detection
- [ ] Predictive maintenance
- [ ] Auto-scaling triggers
- [ ] Advanced workflow orchestration

## 🔧 Development

### Prerequisites
- Node.js 18+
- Redis (for job queues)
- PostgreSQL (shared database)

### Getting Started
```bash
# Navigate to agents directory
cd apps/agents

# Install dependencies
npm install

# Set up configuration
cp .env.template .env

# Start agent supervisor
npm run start

# Run specific agent
npm run agent:monitor
```

### Environment Variables
```bash
# Copy environment template
cp .env.template .env

# Configure required variables:
# DATABASE_URL=postgresql://user:pass@localhost:5432/unykorn
# REDIS_URL=redis://localhost:6379
# DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
# EMAIL_API_KEY=your-email-service-key
```

## 📊 Monitoring & Alerting

### Health Check Dashboard
```typescript
interface AgentHealth {
  name: string;
  status: 'running' | 'stopped' | 'error';
  lastRun: Date;
  nextRun: Date;
  successRate: number;
  errorCount: number;
}
```

### Alert Conditions
- Service downtime > 5 minutes
- Error rate > 5% over 1 hour
- Queue backlog > 1000 jobs
- Database connection failures
- Blockchain RPC failures

### Notification Channels
- **Discord:** Real-time alerts for critical issues
- **Slack:** Business-level notifications
- **Email:** Daily/weekly summary reports
- **Dashboard:** Real-time status visualization

## 🔐 Security Considerations

- **Isolated Execution** - Each agent runs in separate process
- **Privilege Separation** - Minimal database permissions per agent
- **Secure Secrets** - Environment-based secret management
- **Audit Logging** - Complete operation audit trails
- **Rate Limiting** - Prevent resource exhaustion

## 🧪 Testing Strategy

- **Unit Tests** - Individual agent logic testing
- **Integration Tests** - Database and external service integration
- **Schedule Tests** - Cron schedule validation
- **Load Tests** - High-volume job processing

## 🔗 Integration Points

- **Backend API** - Triggers manual agent operations
- **Indexer** - Consumes blockchain data for processing
- **Smart Contracts** - Executes on-chain operations
- **External Services** - Notification and monitoring integrations

## 📚 Related Documentation

- [Backend API](../backend/README.md)
- [Monitoring Guide](../../docs/MONITORING.md)
- [Operations Runbook](../../docs/RUNBOOK.md)
