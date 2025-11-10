// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/MarsTLD.sol";

contract DeployMars is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address REG = vm.envAddress("GLACIER_REGISTRY");

        vm.startBroadcast(pk);
        MarsTLD tld = new MarsTLD(REG);
        vm.stopBroadcast();

        console2.log("MarsTLD:", address(tld));
    }
}
