#!/bin/bash
echo "\xF0\x9F\x9A\x80 Deploying Unykorn Banking Stack"
npx hardhat compile
npx hardhat run scripts/deployContracts.js --network sepolia
docker-compose -f infra/docker-compose.yml up -d
(cd backend && npm run dev &)
(cd frontend && npm run dev &)
