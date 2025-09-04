// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/VaultUSD.sol";
import "../contracts/AssetNFT.sol";
import "../contracts/MockAFO.sol";
import "../contracts/OISW.sol";

contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PK");
        vm.startBroadcast(pk);

        VaultUSD cash = new VaultUSD();
        AssetNFT asset = new AssetNFT();
        MockAFO afo = new MockAFO();
        OISW oisw = new OISW(address(afo));

        // Mint an asset to the seller and cash to the buyer (for demo)
        address buyer = vm.addr(0xB0B);   // demo account
        address seller = vm.addr(0xA11CE);
        asset.mint(seller);
        cash.mint(buyer, 1_000_000e18);

        vm.stopBroadcast();

        console2.log("VaultUSD:", address(cash));
        console2.log("AssetNFT:", address(asset));
        console2.log("AFO:", address(afo));
        console2.log("OISW:", address(oisw));
        console2.log("Buyer:", buyer);
        console2.log("Seller:", seller);
    }
}
