// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  SGEAffiliateSaleV3 — multi-stable compliant sale with:
   - USD & non-USD stablecoins (decimals-safe, oracle-backed)
   - Fee-on-transfer friendly collection (measure net received)
   - ISO 20022-style settlement events (pacs/camt-like)
   - Basel III/IV controls (capital ratio + exposure limits)
   - Optional EIP-2612 permit path
   - Safe ERC-20 flows, pause, 2-step ownership, reentrancy guards
*/

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IAggregatorV3 {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );

    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
}

/** Minimal compliance registry:
 *  - return true if address is allowed to transact (KYC/AML/sanctions ok).
 *  You can swap in your on-chain registry or an attested proxy that caches proofs.
 */
interface IComplianceRegistry {
    function isAllowed(address user) external view returns (bool);
}

/** Optional: Proof-of-Reserves / attestation oracle for SGE or treasury.
 *  If set, sale can require a positive/valid proof before enabling purchases.
 */
interface IAttestationOracle {
    function isValid() external view returns (bool);
}

contract SGEAffiliateSaleV3 is Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ───────────────── Errors ─────────────────
    error ZeroAddress();
    error UnsupportedToken();
    error InactiveToken();
    error BadAmount();
    error StaleOracle();
    error RoundDataInvalid();
    error InvalidBps();
    error InsufficientSGEBalance();
    error ComplianceBlocked();
    error BaselExposureExceeded();
    error BaselCapitalInsufficient();
    error PoRInvalid();

    // ───────────────── Constants ─────────────────
    uint256 public constant ORACLE_STALE_AFTER = 2 hours;
    uint256 public constant USD6 = 1e6; // 6-decimal USD scale
    uint256 private constant BPS = 10_000;

    // ───────────────── Core State ─────────────────
    IERC20 public immutable SGE;
    address public treasury;
    uint256 public sgePer100USD = 1000e18; // SGE per 100 USD (6d)
    bool public require100USDMultiple = true; // exact multiples (100, 200, ... USD)

    // ───────────────── Compliance State ─────────────────
    IComplianceRegistry public compliance; // optional allowlist registry
    IAttestationOracle public proofOfReserves; // optional PoR / attestation
    bool public enforcePoR = false;

    // Basel-like controls (owner updates based on off-chain capital accounting)
    struct BaselParams {
        uint16 minCapitalRatioBps; // e.g., 1200 => 12.00%
        uint256 maxTotalExposureUSD6; // hard cap on total settled USD
        uint256 maxCounterpartyUSD6; // per-buyer cap
    }
    BaselParams public basel;

    // Owner-maintained capital state (eligible capital, RWA)
    uint256 public eligibleCapitalUSD6; // Tier1/Tier1+2 equivalent (attested)
    uint256 public riskWeightedAssetsUSD6;

    // ───────────────── Token & Affiliate State ─────────────────
    struct StableInfo {
        bool active; // allowed for purchase
        bool isUsdPeg; // 1.00 USD peg (no price feed)
        bool measureReceived; // fee-on-transfer support: measure net received
        uint8 decimals; // token decimals
        address priceFeed; // Chainlink-like feed (token/USD, 8d typically) if !isUsdPeg
    }
    mapping(address => StableInfo) public stables;

    struct Affiliate {
        address payout;
        uint16 bps; // out of 10_000
        bool active;
    }
    mapping(bytes32 => Affiliate) public affiliates;

    // ───────────────── Tracking ─────────────────
    uint256 public totalUSDSettled6;
    mapping(address => uint256) public exposureUSD6ByBuyer;

    // ───────────────── Events ─────────────────
    // ISO 20022 inspired: pacs.008 CustomerCreditTransferInitiation-like log
    event ISO20022_Pacs008(
        bytes32 indexed msgId, // business message id (off-chain generated hash ok)
        address indexed debtor, // buyer
        address indexed creditor, // treasury
        address token, // payment instrument
        uint256 tokenAmount, // raw token amount (as transferred/received)
        uint256 usdValue_6d, // computed USD value (6 decimals)
        bytes32 affiliateKey, // affiliate code key
        uint256 sgeToBuyer, // SGE allocated to buyer
        uint256 sgeToAffiliate // SGE allocated to affiliate
    );

    // camt.054 Credit Notification-like settlement log (credits to affiliate)
    event ISO20022_Camt054(
        bytes32 indexed msgId,
        address indexed creditor,
        uint256 sgeAmount,
        bytes32 affiliateKey
    );

    event StableConfigured(
        address indexed token,
        bool active,
        bool isUsdPeg,
        bool measureReceived,
        uint8 decimals,
        address priceFeed
    );
    event TreasuryUpdated(address indexed newTreasury);
    event RateUpdated(uint256 newRate);
    event Exact100OnlySet(bool value);
    event AffiliateConfigured(
        bytes32 indexed key,
        address payout,
        uint16 bps,
        bool active
    );
    event ComplianceSet(address indexed registry);
    event ProofOfReservesSet(address indexed oracle, bool enforced);
    event BaselParamsSet(
        uint16 minCapBps,
        uint256 maxTotalUSD6,
        uint256 maxCounterpartyUSD6
    );
    event CapitalStateUpdated(uint256 eligibleUSD6, uint256 rwaUSD6);

    // ───────────────── Modifiers ─────────────────
    modifier validAddress(address a) {
        if (a == address(0)) revert ZeroAddress();
        _;
    }

    // ───────────────── Constructor ─────────────────
    constructor(address _sge, address _treasury)
        validAddress(_sge)
        validAddress(_treasury)
    {
        SGE = IERC20(_sge);
        treasury = _treasury;

        // Sensible Basel defaults (owner can tighten):
        basel = BaselParams({
            minCapitalRatioBps: 1000, // 10%
            maxTotalExposureUSD6: type(uint256).max,
            maxCounterpartyUSD6: type(uint256).max
        });
    }

    // ───────────────── Admin (Owner) ─────────────────
    function setTreasury(address newTreasury)
        external
        onlyOwner
        validAddress(newTreasury)
    {
        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    function setRatePer100(uint256 newRate) external onlyOwner {
        sgePer100USD = newRate;
        emit RateUpdated(newRate);
    }

    function setExact100Only(bool value) external onlyOwner {
        require100USDMultiple = value;
        emit Exact100OnlySet(value);
    }

    function setComplianceRegistry(address reg) external onlyOwner {
        compliance = IComplianceRegistry(reg);
        emit ComplianceSet(reg);
    }

    function setProofOfReserves(address oracle, bool enforce)
        external
        onlyOwner
    {
        proofOfReserves = IAttestationOracle(oracle);
        enforcePoR = enforce;
        emit ProofOfReservesSet(oracle, enforce);
    }

    function setBaselParams(
        uint16 minCapitalRatioBps,
        uint256 maxTotalExposureUSD6,
        uint256 maxCounterpartyUSD6
    ) external onlyOwner {
        basel = BaselParams(
            minCapitalRatioBps,
            maxTotalExposureUSD6,
            maxCounterpartyUSD6
        );
        emit BaselParamsSet(
            minCapitalRatioBps,
            maxTotalExposureUSD6,
            maxCounterpartyUSD6
        );
    }

    // Update capital state from your off-chain attested accounting/oracle.
    function updateCapitalState(uint256 eligibleUSD6, uint256 rwaUSD6)
        external
        onlyOwner
    {
        eligibleCapitalUSD6 = eligibleUSD6;
        riskWeightedAssetsUSD6 = rwaUSD6;
        emit CapitalStateUpdated(eligibleUSD6, rwaUSD6);
    }

    function configureStable(
        address token,
        bool active,
        bool isUsdPeg,
        bool measureReceived,
        address feed // required if !isUsdPeg
    ) external onlyOwner validAddress(token) {
        if (!isUsdPeg && feed == address(0)) revert ZeroAddress();

        uint8 tokenDecimals = IERC20Metadata(token).decimals();
        stables[token] =
            StableInfo(active, isUsdPeg, measureReceived, tokenDecimals, feed);
        emit StableConfigured(
            token,
            active,
            isUsdPeg,
            measureReceived,
            tokenDecimals,
            feed
        );
    }

    function configureAffiliate(
        string calldata code,
        address payout,
        uint16 bps,
        bool active
    ) external onlyOwner validAddress(payout) {
        if (bps > BPS) revert InvalidBps();
        bytes32 key = keccak256(bytes(code));
        affiliates[key] = Affiliate(payout, bps, active);
        emit AffiliateConfigured(key, payout, bps, active);
    }

    function emergencyWithdraw(
        address token,
        uint256 amount,
        address to
    ) external onlyOwner validAddress(to) {
        IERC20(token).safeTransfer(to, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // ───────────────── Primary Purchase Functions ─────────────────

    /// @notice Standard path (use ERC-20 approve first)
    function buy(
        address token,
        uint256 amount,
        string calldata code,
        bytes32 isoMsgId
    ) external nonReentrant whenNotPaused {
        _preComplianceGuards(msg.sender, token);

        StableInfo memory info = _loadActiveStable(token);
        // 1) Collect payment (supports fee-on-transfer)
        uint256 paid = _collectPayment(token, amount, info);

        // 2) Convert to USD6 (based on net received if measureReceived=true)
        uint256 usd6 = _toUSD6(token, paid, info);
        _validateAmountMultiple(usd6);

        // 3) Basel controls
        _baselGuards(msg.sender, usd6);

        // 4) Compute SGE allocations (buyer + affiliate)
        (uint256 sgeBuyer, uint256 sgeAff, bytes32 affKey) =
            _calcSGE(usd6, code);
        _ensureSGEBalance(sgeBuyer + sgeAff);

        // 5) Transfer SGE
        _sendSGE(msg.sender, sgeBuyer);
        if (sgeAff > 0) {
            _sendSGE(affiliates[affKey].payout, sgeAff);
            emit ISO20022_Camt054(
                isoMsgId,
                affiliates[affKey].payout,
                sgeAff,
                affKey
            );
        }

        // 6) Track exposure
        totalUSDSettled6 += usd6;
        exposureUSD6ByBuyer[msg.sender] += usd6;

        // 7) Emit ISO 20022-style settlement event
        emit ISO20022_Pacs008(
            isoMsgId,
            msg.sender,
            treasury,
            token,
            paid,
            usd6,
            affKey,
            sgeBuyer,
            sgeAff
        );
    }

    /// @notice Gas-less approval path for tokens that implement EIP-2612 permit
    function buyWithPermit(
        address token,
        uint256 amount,
        string calldata code,
        bytes32 isoMsgId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant whenNotPaused {
        // Permit (spender = this contract)
        IERC20Permit(token).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        buy(token, amount, code, isoMsgId);
    }

    // ───────────────── Internal: Compliance / Basel ─────────────────
    function _preComplianceGuards(address buyer, address token)
        internal
        view
    {
        if (address(compliance) != address(0)) {
            if (!compliance.isAllowed(buyer)) revert ComplianceBlocked();
            if (!compliance.isAllowed(treasury)) revert ComplianceBlocked();
        }
        if (enforcePoR && address(proofOfReserves) != address(0)) {
            if (!proofOfReserves.isValid()) revert PoRInvalid();
        }
        if (stables[token].decimals == 0) revert UnsupportedToken();
    }

    function _baselGuards(address buyer, uint256 usd6) internal view {
        // Capital ratio check: eligibleCapital / RWA >= min ratio
        if (basel.minCapitalRatioBps > 0 && riskWeightedAssetsUSD6 > 0) {
            uint256 ratio =
                (eligibleCapitalUSD6 * BPS) / riskWeightedAssetsUSD6;
            if (ratio < basel.minCapitalRatioBps)
                revert BaselCapitalInsufficient();
        }
        // Total exposure (lifetime settled USD) limit
        if (basel.maxTotalExposureUSD6 != type(uint256).max) {
            if (totalUSDSettled6 + usd6 > basel.maxTotalExposureUSD6)
                revert BaselExposureExceeded();
        }
        // Per-counterparty (buyer) limit
        if (basel.maxCounterpartyUSD6 != type(uint256).max) {
            if (
                exposureUSD6ByBuyer[buyer] + usd6 >
                basel.maxCounterpartyUSD6
            ) revert BaselExposureExceeded();
        }
    }

    // ───────────────── Internal: Token / Pricing ─────────────────
    function _loadActiveStable(address token)
        internal
        view
        returns (StableInfo memory info)
    {
        info = stables[token];
        if (!info.active) revert InactiveToken();
    }

    function _collectPayment(
        address token,
        uint256 amount,
        StableInfo memory info
    ) internal returns (uint256 received) {
        if (info.measureReceived) {
            uint256 beforeBal = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            received = IERC20(token).balanceOf(address(this)) - beforeBal;
            // forward net to treasury
            IERC20(token).safeTransfer(treasury, received);
        } else {
            IERC20(token).safeTransferFrom(msg.sender, treasury, amount);
            received = amount;
        }
    }

    function _toUSD6(
        address token,
        uint256 amount,
        StableInfo memory info
    ) internal view returns (uint256) {
        if (info.isUsdPeg) {
            // amount * 1e6 / 10^decimals
            return Math.mulDiv(amount, USD6, 10 ** info.decimals);
        }
        // via oracle (token/USD with feedDecimals)
        IAggregatorV3 feed = IAggregatorV3(info.priceFeed);
        (, int256 price, , uint256 updatedAt, ) = feed.latestRoundData();
        if (price <= 0) revert RoundDataInvalid();
        if (block.timestamp > updatedAt + ORACLE_STALE_AFTER)
            revert StaleOracle();

        uint8 fd = feed.decimals(); // e.g., 8
        // Step1: amount -> price decimals
        uint256 step1 = Math.mulDiv(amount, uint256(price), 10 ** info.decimals);
        // Step2: price decimals -> USD6
        return Math.mulDiv(step1, USD6, 10 ** fd);
    }

    function _validateAmountMultiple(uint256 usd6) internal view {
        if (!require100USDMultiple) return;
        uint256 hundred = 100 * USD6;
        if (usd6 % hundred != 0) revert BadAmount();
    }

    function _calcSGE(uint256 usd6, string calldata code)
        internal
        view
        returns (
            uint256 sgeBuyer,
            uint256 sgeAff,
            bytes32 key
        )
    {
        uint256 units = usd6 / (100 * USD6); // number of 100 USD blocks
        sgeBuyer = units * sgePer100USD;
        key = keccak256(bytes(code));
        Affiliate memory aff = affiliates[key];
        if (aff.active && aff.bps > 0) {
            sgeAff = (sgeBuyer * aff.bps) / BPS;
            sgeBuyer -= sgeAff;
        }
    }

    function _ensureSGEBalance(uint256 req) internal view {
        if (SGE.balanceOf(address(this)) < req) revert InsufficientSGEBalance();
    }

    function _sendSGE(address to, uint256 amount) internal {
        SGE.safeTransfer(to, amount);
    }

    // ───────────────── Safety ─────────────────
    receive() external payable {
        revert("ETH_NOT_ACCEPTED");
    }

    fallback() external payable {
        revert("INVALID_CALL");
    }
}

