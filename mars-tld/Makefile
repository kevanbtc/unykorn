include .env
export

build:
	forge build

deploy:
	forge script scripts/04_one_shot_deploy.s.sol:OneShotMars \
	 --rpc-url $$RPC_URL --broadcast -vvvv --legacy

apply:
	forge script scripts/02_apply_params_from_dot3.s.sol:ApplyParamsFromDot3 \
	 --rpc-url $$RPC_URL --broadcast -vvvv

mint:
	forge script scripts/03_mint_subdomain.s.sol:MintSubdomain \
	 --rpc-url $$RPC_URL --broadcast -vvvv
