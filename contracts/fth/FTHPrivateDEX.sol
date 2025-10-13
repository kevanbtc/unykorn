// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title FTHPrivateDEX - Private automated market maker for FTH ecosystem
/// @notice Supports USDF/FTHG, USDF/XRP, FTHG/XRP pairs with holder discounts
/// @dev Simplified constant product AMM with 10% discount for qualified holders
contract FTHPrivateDEX is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant LP_ROLE = keccak256("LP_ROLE");

    /// @notice Trading fee in basis points (25 = 0.25%)
    uint256 public constant TRADING_FEE_BPS = 25;
    
    /// @notice Discount for qualified holders in basis points (1000 = 10%)
    uint256 public constant HOLDER_DISCOUNT_BPS = 1000;
    
    /// @notice Minimum holdings to qualify for discount (in wei)
    uint256 public qualificationThreshold;

    /// @notice Trading pair structure
    struct TradingPair {
        address tokenA;
        address tokenB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
        bool active;
    }

    /// @notice Liquidity provider position
    struct LPPosition {
        uint256 liquidity;
        uint256 rewardsEarned;
    }

    /// @notice Trading pairs by ID
    mapping(bytes32 => TradingPair) public pairs;
    
    /// @notice LP positions: pairId => provider => position
    mapping(bytes32 => mapping(address => LPPosition)) public lpPositions;
    
    /// @notice Accumulated fees per pair
    mapping(bytes32 => uint256) public accumulatedFees;
    
    /// @notice Reference to USDF token for qualification check
    address public usdfToken;
    
    /// @notice Reference to FTHG token for qualification check
    address public fthgToken;

    event PairCreated(bytes32 indexed pairId, address tokenA, address tokenB);
    event LiquidityAdded(bytes32 indexed pairId, address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(bytes32 indexed pairId, address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event Swap(bytes32 indexed pairId, address indexed trader, address tokenIn, uint256 amountIn, uint256 amountOut, bool discountApplied);
    event FeesCollected(bytes32 indexed pairId, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the private DEX
    /// @param treasury Treasury address with admin privileges
    /// @param _usdfToken USDF token address
    /// @param _fthgToken FTHG token address
    /// @param _qualificationThreshold Minimum holdings for discount (in wei)
    function initialize(
        address treasury,
        address _usdfToken,
        address _fthgToken,
        uint256 _qualificationThreshold
    ) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, treasury);
        _grantRole(OPERATOR_ROLE, treasury);
        _grantRole(LP_ROLE, treasury);

        usdfToken = _usdfToken;
        fthgToken = _fthgToken;
        qualificationThreshold = _qualificationThreshold;
    }

    /// @notice Create a new trading pair
    /// @param tokenA First token address
    /// @param tokenB Second token address
    function createPair(address tokenA, address tokenB) external onlyRole(OPERATOR_ROLE) {
        require(tokenA != tokenB, "DEX: identical tokens");
        bytes32 pairId = getPairId(tokenA, tokenB);
        require(!pairs[pairId].active, "DEX: pair exists");

        pairs[pairId] = TradingPair({
            tokenA: tokenA,
            tokenB: tokenB,
            reserveA: 0,
            reserveB: 0,
            totalLiquidity: 0,
            active: true
        });

        emit PairCreated(pairId, tokenA, tokenB);
    }

    /// @notice Add liquidity to a pair
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @param amountA Amount of tokenA
    /// @param amountB Amount of tokenB
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external onlyRole(LP_ROLE) nonReentrant returns (uint256 liquidity) {
        bytes32 pairId = getPairId(tokenA, tokenB);
        TradingPair storage pair = pairs[pairId];
        require(pair.active, "DEX: pair not active");

        // Transfer tokens
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        // Calculate liquidity shares
        if (pair.totalLiquidity == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(
                (amountA * pair.totalLiquidity) / pair.reserveA,
                (amountB * pair.totalLiquidity) / pair.reserveB
            );
        }

        require(liquidity > 0, "DEX: insufficient liquidity");

        // Update reserves and positions
        pair.reserveA += amountA;
        pair.reserveB += amountB;
        pair.totalLiquidity += liquidity;
        lpPositions[pairId][msg.sender].liquidity += liquidity;

        emit LiquidityAdded(pairId, msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Remove liquidity from a pair
    /// @param tokenA First token address
    /// @param tokenB Second token address
    /// @param liquidity Amount of liquidity to remove
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity
    ) external onlyRole(LP_ROLE) nonReentrant returns (uint256 amountA, uint256 amountB) {
        bytes32 pairId = getPairId(tokenA, tokenB);
        TradingPair storage pair = pairs[pairId];
        LPPosition storage position = lpPositions[pairId][msg.sender];

        require(position.liquidity >= liquidity, "DEX: insufficient liquidity");

        // Calculate token amounts
        amountA = (liquidity * pair.reserveA) / pair.totalLiquidity;
        amountB = (liquidity * pair.reserveB) / pair.totalLiquidity;

        // Update state
        position.liquidity -= liquidity;
        pair.totalLiquidity -= liquidity;
        pair.reserveA -= amountA;
        pair.reserveB -= amountB;

        // Transfer tokens
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit LiquidityRemoved(pairId, msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Swap tokens with automatic discount for qualified holders
    /// @param tokenIn Input token address
    /// @param tokenOut Output token address
    /// @param amountIn Amount of input tokens
    /// @param minAmountOut Minimum output tokens (slippage protection)
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external nonReentrant returns (uint256 amountOut) {
        bytes32 pairId = getPairId(tokenIn, tokenOut);
        TradingPair storage pair = pairs[pairId];
        require(pair.active, "DEX: pair not active");

        // Check if trader qualifies for discount
        bool qualified = isQualifiedForDiscount(msg.sender);

        // Calculate effective fee
        uint256 effectiveFee = qualified
            ? (TRADING_FEE_BPS - (TRADING_FEE_BPS * HOLDER_DISCOUNT_BPS) / 10000)
            : TRADING_FEE_BPS;

        // Get reserves
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == pair.tokenA
            ? (pair.reserveA, pair.reserveB)
            : (pair.reserveB, pair.reserveA);

        // Calculate output amount with fee
        uint256 amountInWithFee = amountIn * (10000 - effectiveFee);
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);

        require(amountOut >= minAmountOut, "DEX: insufficient output");
        require(amountOut < reserveOut, "DEX: insufficient liquidity");

        // Update reserves
        if (tokenIn == pair.tokenA) {
            pair.reserveA += amountIn;
            pair.reserveB -= amountOut;
        } else {
            pair.reserveB += amountIn;
            pair.reserveA -= amountOut;
        }

        // Track fees
        uint256 feeAmount = (amountIn * effectiveFee) / 10000;
        accumulatedFees[pairId] += feeAmount;

        // Execute swap
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        emit Swap(pairId, msg.sender, tokenIn, amountIn, amountOut, qualified);
    }

    /// @notice Check if address qualifies for holder discount
    /// @param account Address to check
    /// @return True if qualified for discount
    function isQualifiedForDiscount(address account) public view returns (bool) {
        uint256 usdfBalance = IERC20(usdfToken).balanceOf(account);
        uint256 fthgBalance = IERC20(fthgToken).balanceOf(account);
        return (usdfBalance >= qualificationThreshold) || (fthgBalance >= qualificationThreshold);
    }

    /// @notice Get pair ID from token addresses
    /// @param tokenA First token
    /// @param tokenB Second token
    /// @return Deterministic pair ID
    function getPairId(address tokenA, address tokenB) public pure returns (bytes32) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return keccak256(abi.encodePacked(token0, token1));
    }

    /// @notice Update qualification threshold
    /// @param newThreshold New threshold value
    function setQualificationThreshold(uint256 newThreshold) external onlyRole(OPERATOR_ROLE) {
        qualificationThreshold = newThreshold;
    }

    /// @dev Calculate square root (for liquidity calculation)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /// @dev Return minimum of two values
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @dev Required by UUPS
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
