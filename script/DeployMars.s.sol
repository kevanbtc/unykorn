// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/VTV.sol";

contract DeployMars is Script {
    function run() external {
        vm.startBroadcast();
        new VTV();
        vm.stopBroadcast();
    }
}
