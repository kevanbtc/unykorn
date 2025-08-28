# Contributing to UNYKORN ATLAS

Thanks for contributing!

## Tooling
- Foundry (Solidity)
- Go 1.21+
- Node 20+ (for solhint)
- pre-commit (optional but recommended)
- Docker (optional, handy for Foundry behind proxies)

## Workflow
1. Branch from `main`.
2. Install deps:
   ```bash
   forge install OpenZeppelin/openzeppelin-contracts-upgradeable@v5.0.2 \
                OpenZeppelin/openzeppelin-contracts@v5.0.2 \
                foundry-rs/forge-std
   (cd go-bus && go mod tidy)
   npm i
   ```
3. Build & test:
   ```bash
   forge build && forge test -vv
   (cd go-bus && go build ./cmd/iso-bus && go test ./... -v)
   ```
4. Lint:
   ```bash
   npm run lint:sol
   (cd go-bus && golangci-lint run)
   ```
5. Open a PR with a clear summary. CI must pass.

## Commits & releases

* Use Conventional Commits: `type(scope): summary`
* Tag releases as `vMAJOR.MINOR.PATCH` to trigger the Release workflow.

## Security

Please see `SECURITY.md` for how to report vulnerabilities.
