#!/usr/bin/env bash
set -euo pipefail

# Requires: PRIVATE_KEY, RPC_URL, GLACIER_REGISTRY
forge script scripts/01_deploy_mars.s.sol:DeployMars \
  --rpc-url "$RPC_URL" --broadcast -vvvv

# After deploy, export the MARS_TLD from the previous console log:
# export MARS_TLD=0x...  (paste it)
forge script scripts/02_apply_params_from_dot3.s.sol:ApplyParamsFromDot3 \
  --rpc-url "$RPC_URL" --broadcast -vvvv
