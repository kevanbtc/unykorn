.PHONY: build node deploy dvp clean

build:
forge build

node:
reth node --dev --http --http.addr 0.0.0.0 --http.api admin,eth,net,web3,debug,txpool,trace --ws --ws.addr 0.0.0.0

deploy:
DEPLOYER_PK=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d \
forge script script/Deploy.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast -vvvv

dvp:
./dev/demo-dvp.sh

clean:
rm -rf out cache
