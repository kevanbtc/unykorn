// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

import {CompliantStablecoin} from "../src/CompliantStablecoin.sol";
import {CompliantStableFactory} from "../src/CompliantStableFactory.sol";
import {IComplianceRegistry} from "../src/interfaces/IComplianceRegistry.sol";
import {SimpleComplianceRegistry} from "../src/registries/SimpleComplianceRegistry.sol";
import {ChainlinkPoRAdapter} from "../src/adapters/ChainlinkPoRAdapter.sol";
import {IProofOfReserveOracle} from "../src/interfaces/IProofOfReserveOracle.sol";

contract DeployAll is Script {
    using stdJson for string;

    struct Roles { address minter; address compliance; address pauser; address law; address upgrader; }
    struct PoRConf { string ptype; address feed; uint256 staleAfter; }

    string public configPath;

    function _eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function run() external {
        configPath = vm.envOr("CONFIG", string("script/config/multi.example.json"));
        string memory json = vm.readFile(configPath);

        address admin = _asAddr(json.readString(".admin"));
        bool deploySimpleReg = json.readBool(".deploySimpleComplianceRegistry");
        address registryAddr = _asAddr(json.readString(".complianceRegistry"));

        PoRConf memory por;
        por.ptype      = json.readString(".por.type");
        por.feed       = json.readAddress(".por.feed");
        por.staleAfter = uint256(json.readUint(".por.staleAfter"));

        Roles memory roles;
        roles.minter     = _asAddr(json.readString(".roles.minter"));
        roles.compliance = _asAddr(json.readString(".roles.compliance"));
        roles.pauser     = _asAddr(json.readString(".roles.pauser"));
        roles.law        = _asAddr(json.readString(".roles.law"));
        roles.upgrader   = _asAddr(json.readString(".roles.upgrader"));

        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        IComplianceRegistry registry;
        if (deploySimpleReg) {
            registry = new SimpleComplianceRegistry(admin);
            registryAddr = address(registry);
        } else {
            require(registryAddr != address(0), "registry=0");
            registry = IComplianceRegistry(registryAddr);
        }

        IProofOfReserveOracle porGlobal;
        if (_eq(por.ptype, "chainlink")) {
            porGlobal = new ChainlinkPoRAdapter(por.feed, por.staleAfter);
        } else {
            revert("por.type unsupported");
        }

        CompliantStablecoin impl = new CompliantStablecoin();
        CompliantStableFactory factory = new CompliantStableFactory(address(impl));

        console2.log("Registry :", registryAddr);
        console2.log("PoR(glb) :", address(porGlobal));
        console2.log("Impl     :", address(impl));
        console2.log("Factory  :", address(factory));

        uint256 instCount = json.readUint(".instances.length");
        for (uint256 i; i < instCount; i++) {
            string memory base = string.concat(".instances[", vm.toString(i), "]");
            string memory name_ = json.readString(string.concat(base, ".name"));
            string memory symbol = json.readString(string.concat(base, ".symbol"));
            uint8 decimals_ = uint8(json.readUint(string.concat(base, ".decimals")));
            string memory currencyCode = json.readString(string.concat(base, ".currencyCode"));
            string memory collateralType = json.readString(string.concat(base, ".collateralType"));
            bytes32 jurisdiction = _toBytes32(json.readString(string.concat(base, ".jurisdiction")));
            string memory policyURI = json.readString(string.concat(base, ".policyURI"));
            address lawEscrow = json.readAddress(string.concat(base, ".lawEnforcementEscrow"));
            uint16 minCR = uint16(json.readUint(string.concat(base, ".minCollateralRatioBps")));

            CompliantStableFactory.Params memory p = CompliantStableFactory.Params({
                name: name_,
                symbol: symbol,
                decimals: decimals_,
                admin: admin,
                complianceRegistry: registryAddr,
                oracle: address(porGlobal),
                minCollateralRatioBps: minCR,
                currencyCode: currencyCode,
                collateralType: collateralType,
                jurisdiction: jurisdiction,
                policyURI: policyURI,
                lawEnforcementEscrow: lawEscrow
            });

            address proxy = factory.createStable(p);
            console2.log("Deployed:", symbol, proxy);

            CompliantStablecoin t = CompliantStablecoin(payable(proxy));
            bytes32 COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
            bytes32 MINTER_ROLE     = keccak256("MINTER_ROLE");
            bytes32 PAUSER_ROLE     = keccak256("PAUSER_ROLE");
            bytes32 LAW_ROLE        = keccak256("LAW_ROLE");
            bytes32 UPGRADER_ROLE   = keccak256("UPGRADER_ROLE");

            t.grantRole(MINTER_ROLE, roles.minter);
            t.grantRole(COMPLIANCE_ROLE, roles.compliance);
            t.grantRole(PAUSER_ROLE, roles.pauser);
            t.grantRole(LAW_ROLE, roles.law);
            t.grantRole(UPGRADER_ROLE, roles.upgrader);
        }

        vm.stopBroadcast();
    }

    function _toBytes32(string memory s) internal pure returns (bytes32 out) {
        bytes memory b = bytes(s);
        if (b.length == 0) return 0x0;
        require(b.length <= 32, "jurisdiction>32");
        assembly { out := mload(add(s, 32)) }
    }

    function _asAddr(string memory raw) internal view returns (address) {
        bytes memory b = bytes(raw);
        if (b.length == 0 || keccak256(b) == keccak256(bytes("$DEPLOYER"))) {
            return vm.addr(vm.envUint("PRIVATE_KEY"));
        }
        return vm.parseAddress(raw);
    }
}
