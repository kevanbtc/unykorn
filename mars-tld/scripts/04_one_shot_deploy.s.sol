// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/MarsTLD.sol";
import "../contracts/IGlacierRegistry.sol";
import "../contracts/IControllerLike.sol";

contract OneShotMars is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address REG = vm.envAddress("GLACIER_REGISTRY");
        bytes32 DOT3 = keccak256(abi.encodePacked(".3"));

        vm.startBroadcast(pk);
        MarsTLD tld = new MarsTLD(REG);

        (, address resolver, address controller, address fee, address comp, address tba) =
            IGlacierRegistry(REG).tldInfo(DOT3);

        tld.applyParams(resolver, controller, fee, comp, tba);

        address deployer = vm.addr(pk);
        IControllerLike ctl = IControllerLike(controller);
        string[10] memory labels = [
            "dao",
            "gov",
            "vault",
            "id",
            "oracle",
            "court",
            "bridge",
            "rwa",
            "energy",
            "carbon"
        ];
        for (uint256 i = 0; i < labels.length; i++) {
            ctl.mint(deployer, labels[i], ".mars");
        }
        vm.stopBroadcast();

        console2.log("MarsTLD:", address(tld));
    }
}
