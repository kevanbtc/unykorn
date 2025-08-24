// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/IControllerLike.sol";

contract MintSubdomain is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address CONTROLLER = vm.envAddress("CONTROLLER");
        address TO = vm.envAddress("RECIPIENT");
        string memory LABEL = vm.envString("LABEL"); // e.g., "dao"

        vm.startBroadcast(pk);
        uint256 tokenId = IControllerLike(CONTROLLER).mint(TO, LABEL, ".mars");
        vm.stopBroadcast();

        console2.log("Minted:", tokenId);
    }
}
