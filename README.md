# FTH Platform Monorepo

This repository provides a scaffold for Future Tech Holdings (FTH),
covering smart contracts, a backend API with AI agent stubs, a Next.js
frontend, and documentation templates.

## Structure

```
contracts/            Solidity contracts for tokens and cash flow routing
backend/              Express server with AI agent stubs
  ├── ai_agents/      Financial model and document generators
  ├── routes/         Example REST endpoints
  └── services/       Placeholder integration modules
frontend/             Next.js app for project input and dashboards
  ├── pages/          Basic pages for workflow
  └── components/     Shared UI components
docs/                 Regulatory and investor document templates
```

Each section contains minimal placeholder code so the project can be
opened in a development environment and expanded.

## Development

Install dependencies and compile contracts:

```bash
npm install
npm run compile
```

### Offline compiler setup

Hardhat normally downloads the Solidity compiler at runtime. If network
access is restricted, install the compiler locally and Hardhat will use
it without reaching out to the internet:

```bash
npm install --save-dev solc@0.8.20
```

For Slither analysis, a matching native `solc` is also required:

```bash
pip3 install slither-analyzer solc-select
solc-select install 0.8.20
solc-select use 0.8.20
```

Hardhat will automatically use the native compiler if it is available at
`/usr/bin/solc`, allowing compilation without network access.

### Docker development environment

To avoid manual toolchain setup, a Docker configuration is provided. It
bundles Node.js, `solc` 0.8.20, and Slither. Build and open a shell with:

```bash
docker compose build
docker compose run --rm dev bash
```

Inside the container you can run `npm test` or `npm run slither` without
requiring outbound network connections.

### Static Analysis

Run Slither to perform basic static analysis of the Solidity contracts:

```bash
npm run slither
```

### Tests

Hardhat tests cover the compliance registry and token interactions. Compile once before running tests:

```bash
npm run compile
npm test
```
