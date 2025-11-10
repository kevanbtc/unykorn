// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/IGlacierRegistry.sol";

contract ReadDot3 is Script {
    function run() external view {
        address REG = vm.envAddress("GLACIER_REGISTRY");
        bytes32 DOT3 = keccak256(abi.encodePacked(".3"));
        ( ,address resolver,address controller,address fee,address comp,address tba) =
            IGlacierRegistry(REG).tldInfo(DOT3);

        console2.log("Resolver:   ", resolver);
        console2.log("Controller: ", controller);
        console2.log("FeeModel:   ", fee);
        console2.log("Compliance: ", comp);
        console2.log("TBA Impl:   ", tba);
    }
}
