# Release Checklist

This guide walks through creating a new version tag and verifying artifacts.

## 1. Run tests and linters

Ensure all tests and linters pass before tagging:

```bash
npm run lint:sol
(cd go-bus && golangci-lint run)
(cd go-bus && go test ./... -v)
# Foundry tests via local install or Docker
forge test -vv || docker run --rm -v "$PWD":/work -w /work ghcr.io/foundry-rs/foundry:latest forge test -vv
```

## 2. Tag the release

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

## 3. Verify GitHub Actions

Confirm all workflows succeed for the tag:
- Solidity (Foundry)
- Go ISO-bus
- Go Lint
- Solidity Lint (solhint)
- Docker (ISO-bus → GHCR)
- Release (Binaries + Artifacts)

## 4. Inspect release assets

Download assets from the GitHub release page and confirm:
- `foundry_artifacts.zip`
- `iso-bus_<os>_<arch>.tar.gz` for each target

## 5. Verify Docker image

```bash
docker pull ghcr.io/ORG_SLUG/atlas-iso-bus:latest
docker run --rm -p 8080:8080 ghcr.io/ORG_SLUG/atlas-iso-bus:latest
curl -sf http://localhost:8080/healthz
```

## 6. Publish notes

Add release notes summarizing changes and link to relevant PRs or issues.

