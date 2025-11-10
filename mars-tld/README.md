# .mars TLD (GlacierMint / Unykorn)

Deploy `.mars` mirroring `.3` parameters.

## 0) Environment
```bash
cp .env.example .env
# generate a fresh PRIVATE_KEY and prefix with 0x
openssl rand -hex 32
```
Fill `PRIVATE_KEY`, `RPC_URL`, and `GLACIER_REGISTRY` in `.env`.

## 1) Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```
Alternatively install via Homebrew or Docker if curl is blocked.

## 2) Build and deploy
```bash
cd mars-tld
make build      # forge build
make deploy     # one-shot deploy script
```
`make deploy` runs `scripts/04_one_shot_deploy.s.sol:OneShotMars` which deploys the TLD, applies `.3` params, and mints reserved labels.

## 3) Manual operations
Inspect `.3` params:
```bash
forge script scripts/00_read_dot3_params.s.sol:ReadDot3 --rpc-url $RPC_URL
```
Apply parameters separately:
```bash
forge script scripts/02_apply_params_from_dot3.s.sol:ApplyParamsFromDot3 --rpc-url $RPC_URL --broadcast -vvvv
```
Mint a subdomain:
```bash
forge script scripts/03_mint_subdomain.s.sol:MintSubdomain --rpc-url $RPC_URL --broadcast -vvvv
```
