// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/IGlacierRegistry.sol";
import "../contracts/MarsTLD.sol";

contract ApplyParamsFromDot3 is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address REG = vm.envAddress("GLACIER_REGISTRY");
        address MARS = vm.envAddress("MARS_TLD"); // output from 01_deploy_mars

        bytes32 DOT3 = keccak256(abi.encodePacked(".3"));
        ( ,address resolver,address controller,address fee,address comp,address tba) =
            IGlacierRegistry(REG).tldInfo(DOT3);

        vm.startBroadcast(pk);
        MarsTLD(MARS).applyParams(resolver, controller, fee, comp, tba);
        vm.stopBroadcast();

        console2.log("Applied params from .3 to .mars");
    }
}
