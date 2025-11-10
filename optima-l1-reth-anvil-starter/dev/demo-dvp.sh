#!/usr/bin/env bash
set -euo pipefail
: "${VUSD:?set VUSD address}"
: "${ASSET:?set ASSET address}"
: "${OISW:?set OISW address}"
BUYER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
SELLER=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
cast rpc anvil_impersonateAccount $BUYER >/dev/null
cast rpc anvil_impersonateAccount $SELLER >/dev/null
cast send $VUSD "approve(address,uint256)" $OISW 1000000000000000000000 --from $BUYER
cast send $ASSET "approve(address,uint256)" $OISW 1 --from $SELLER
cast send $OISW "settleDvP((address,address,address,address,uint256,uint256,bytes32,bytes))" "($VUSD,$ASSET,$BUYER,$SELLER,100000000000000000000,1,0x5247415f56414c5f5631,0x)" --from $BUYER
