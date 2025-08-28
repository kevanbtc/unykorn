# UNYKORN ATLAS

> **How to use this doc**  
> This repo is flattened so you (or Codex) can copy the sections into the right folders and run the provided commands. Once pushed to GitHub, CI/CD runs automatically (Foundry, Go, linting, Docker). Tagging a release (`vX.Y.Z`) packages artifacts and publishes binaries.

## Contents
- **Solidity** smart contracts (`src/`) built with [Foundry](https://github.com/foundry-rs/foundry). Includes:
  - UUPS-upgradeable, role-based stablecoin
  - Factory for deploying multiple stables
  - Settlement router + rails (CBDC and mock)
  - Proof-of-Reserve and Travel Rule hooks
- **Go ISO-bus** service (`go-bus/`) that reads YAML/JSON config and exposes ISO 20022-style endpoints.

## Layout
```
src/              # Solidity contracts
script/           # Deploy scripts + config
test/             # Foundry tests
go-bus/           # ISO-bus (Go)
.github/workflows # CI/CD for Foundry, Go, Solhint, Docker, Releases
```

## Solidity (Foundry)

Build & test:
```bash
forge build
forge test -vv
```

If you’re behind a proxy, use the Foundry Docker image instead:

```bash
docker run --rm -v "$PWD":/work -w /work ghcr.io/foundry-rs/foundry:latest forge build
docker run --rm -v "$PWD":/work -w /work ghcr.io/foundry-rs/foundry:latest forge test -vv
```

## Go ISO-bus

Run locally:

```bash
cd go-bus
go mod tidy
go run ./cmd/iso-bus --config ./config/config.yaml
```

Endpoints:

* `GET  /healthz`
* `POST /iso/pacs008`
* `POST /callbacks/hold`

## Docker ISO-bus

```bash
docker build -t ghcr.io/ORG_SLUG/atlas-iso-bus:dev -f go-bus/Dockerfile go-bus
docker run --rm -p 8080:8080 ghcr.io/ORG_SLUG/atlas-iso-bus:dev
```

## CI/CD

* **Foundry build/test** (`.github/workflows/solidity.yml`)
* **Go build/test/vet** (`go.yml`)
* **Go lint** with golangci-lint (`golangci.yml`) — pin `v1.60.3` locally
* **Solhint** lint (`solhint.yml`)
* **Docker → GHCR** (`docker.yml`)
* **Release** on tags `v*.*.*`: Go binaries + `foundry_artifacts.zip`

## License

MIT

