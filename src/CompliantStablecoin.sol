// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {IComplianceRegistry} from "./interfaces/IComplianceRegistry.sol";
import {IProofOfReserveOracle} from "./interfaces/IProofOfReserveOracle.sol";

contract CompliantStablecoin is
    Initializable,
    ERC20PermitUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
    bytes32 public constant MINTER_ROLE     = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE     = keccak256("PAUSER_ROLE");
    bytes32 public constant LAW_ROLE        = keccak256("LAW_ROLE");
    bytes32 public constant UPGRADER_ROLE   = keccak256("UPGRADER_ROLE");

    IComplianceRegistry public compliance;
    IProofOfReserveOracle public oracle;
    uint16 public minCollateralRatioBps;
    bytes32 public jurisdiction;
    string  public currencyCode;
    string  public collateralType;
    string  public policyURI;
    address public lawEnforcementEscrow;
    uint8   private _customDecimals;

    mapping(address => bool) public frozen;

    event OracleUpdated(address indexed oracle);
    event ComplianceRegistryUpdated(address indexed registry);
    event AccountFrozen(address indexed account, bool frozen);
    event Seized(address indexed from, address indexed to, uint256 amount);
    event TravelRuleTransfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        string originatorVasp,
        string beneficiaryVasp,
        bytes32 metadataHash,
        string metadataURI
    );
    event ISO20022Log(bytes32 messageType, string messageId, string docURI, bytes32 docHash);

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8   decimals_,
        address admin,
        address complianceRegistry_,
        address oracle_,
        uint16  minCRBps_,
        string memory currencyCode_,
        string memory collateralType_,
        bytes32 jurisdiction_,
        string memory policyURI_,
        address lawEscrow_
    ) public initializer {
        require(admin != address(0), "admin=0");

        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _customDecimals = decimals_;
        compliance = IComplianceRegistry(complianceRegistry_);
        oracle = IProofOfReserveOracle(oracle_);
        minCollateralRatioBps = minCRBps_;
        currencyCode = currencyCode_;
        collateralType = collateralType_;
        jurisdiction = jurisdiction_;
        policyURI = policyURI_;
        lawEnforcementEscrow = lawEscrow_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(COMPLIANCE_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function decimals() public view override returns (uint8) { return _customDecimals; }

    function maxSupplyAllowed() public view returns (uint256) {
        uint256 reservesUSD18 = oracle.collateralValueUSD18();
        uint256 allowedUSD18 = reservesUSD18 * 10000 / uint256(minCollateralRatioBps);
        return (allowedUSD18 * (10 ** _customDecimals)) / 1e18;
    }

    function setOracle(address newOracle) external onlyRole(COMPLIANCE_ROLE) {
        require(newOracle != address(0), "oracle=0");
        oracle = IProofOfReserveOracle(newOracle);
        emit OracleUpdated(newOracle);
    }

    function setComplianceRegistry(address reg) external onlyRole(COMPLIANCE_ROLE) {
        require(reg != address(0), "registry=0");
        compliance = IComplianceRegistry(reg);
        emit ComplianceRegistryUpdated(reg);
    }

    function setMinCollateralRatioBps(uint16 bps) external onlyRole(COMPLIANCE_ROLE) {
        require(bps >= 10000, "min 100%");
        minCollateralRatioBps = bps;
    }

    function setLawEnforcementEscrow(address escrow) external onlyRole(LAW_ROLE) {
        require(escrow != address(0), "escrow=0");
        lawEnforcementEscrow = escrow;
    }

    function pause() external onlyRole(PAUSER_ROLE) { _pause(); }
    function unpause() external onlyRole(PAUSER_ROLE) { _unpause(); }

    function freeze(address account, bool frz) external onlyRole(LAW_ROLE) {
        frozen[account] = frz;
        emit AccountFrozen(account, frz);
    }

    function forceTransfer(address from, address to, uint256 amount) external onlyRole(LAW_ROLE) {
        require(!frozen[from] && !frozen[to], "frozen");
        _transfer(from, to, amount);
    }

    function seize(address from, uint256 amount) external onlyRole(LAW_ROLE) {
        require(lawEnforcementEscrow != address(0), "escrow not set");
        _transfer(from, lawEnforcementEscrow, amount);
        emit Seized(from, lawEnforcementEscrow, amount);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        require(_complianceOK(address(0), to), "to blocked");
        require(oracle.isValid(), "oracle invalid");
        require(totalSupply() + amount <= maxSupplyAllowed(), "exceeds PoR cap");
        _mint(to, amount);
    }

    function burn(uint256 amount) external whenNotPaused {
        _burn(_msgSender(), amount);
    }

    function transferWithData(
        address to,
        uint256 amount,
        string calldata originatorVasp,
        string calldata beneficiaryVasp,
        bytes32 metadataHash,
        string calldata metadataURI
    ) external whenNotPaused returns (bool) {
        _transfer(_msgSender(), to, amount);
        emit TravelRuleTransfer(_msgSender(), to, amount, originatorVasp, beneficiaryVasp, metadataHash, metadataURI);
        return true;
    }

    function emitISO20022(bytes32 messageType, string calldata messageId, string calldata docURI, bytes32 docHash)
        external onlyRole(COMPLIANCE_ROLE)
    {
        emit ISO20022Log(messageType, messageId, docURI, docHash);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal override whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
        if (from != address(0)) {
            require(!frozen[from], "from frozen");
            require(_complianceOK(from, address(0)), "from blocked");
        }
        if (to != address(0)) {
            require(!frozen[to], "to frozen");
            require(_complianceOK(address(0), to), "to blocked");
        }
    }

    function _complianceOK(address from, address to) internal view returns (bool) {
        if (from != address(0) && !compliance.isAllowed(from)) return false;
        if (to   != address(0) && !compliance.isAllowed(to))   return false;
        return true;
    }
}
