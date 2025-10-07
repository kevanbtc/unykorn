# Tokenomics

*Token Economics and Distribution Model*

---

## Overview

The Unykorn token (ticker: TBD) is designed to align incentives across all platform stakeholders while ensuring sustainable growth and governance participation. This document outlines the token supply, allocation, vesting schedules, and economic mechanisms.

**Note**: This is a template framework. Specific parameters should be customized based on project requirements, legal considerations, and market conditions.

---

## Token Supply

### Total Supply
- **Maximum Supply**: 1,000,000,000 tokens (1 billion)
- **Initial Circulating Supply**: 200,000,000 tokens (20%)
- **Token Standard**: ERC-20 (EVM chains), SPL Token (Solana)
- **Decimals**: 18 (EVM) / 9 (Solana)
- **Minting**: Fixed supply, no additional minting

### Supply Schedule

| Period | Tokens Released | Cumulative % | Notes |
|--------|-----------------|--------------|-------|
| TGE (Token Generation Event) | 200M | 20% | Initial liquidity + airdrops |
| Month 6 | 100M | 30% | First vesting unlock |
| Month 12 | 150M | 45% | Community and ecosystem |
| Month 18 | 150M | 60% | Continued distribution |
| Month 24 | 200M | 80% | Major unlock period |
| Month 36 | 200M | 100% | Final distribution |

---

## Token Allocation

### Distribution Breakdown

| Category | Allocation | Tokens | Vesting | Cliff |
|----------|-----------|---------|---------|-------|
| **Community Airdrop** | 25% | 250M | 6 months linear | None |
| **Liquidity Bootstrap** | 20% | 200M | Immediate | None |
| **Ecosystem Fund** | 20% | 200M | 36 months linear | 6 months |
| **Team & Advisors** | 15% | 150M | 24 months linear | 12 months |
| **Treasury & Operations** | 10% | 100M | 24 months linear | 6 months |
| **Strategic Partners** | 5% | 50M | 18 months linear | 6 months |
| **Private Sale** | 5% | 50M | 12 months linear | 3 months |
| **Total** | **100%** | **1,000M** | | |

### Detailed Allocation

#### 1. Community Airdrop (25% - 250M tokens)

**Purpose**: Reward early adopters, incentivize platform usage, and build community

**Distribution Methods**:
- Early user rewards: 100M (40%)
- Token launch participants: 75M (30%)
- NFT holders: 50M (20%)
- Community contributors: 25M (10%)

**Vesting**: 
- 50% unlocked at TGE
- 50% vested linearly over 6 months
- No cliff period

**Eligibility Criteria**:
- Deployed token on platform before [date]
- Held minimum balance of platform tokens
- Active participation in governance
- Contributed to ecosystem (content, code, community)

---

#### 2. Liquidity Bootstrap (20% - 200M tokens)

**Purpose**: Provide initial liquidity on decentralized exchanges

**Allocation**:
- Uniswap V3 (Ethereum): 60M (30%)
- SushiSwap (Multiple chains): 40M (20%)
- Raydium (Solana): 40M (20%)
- Other DEXs: 40M (20%)
- Market making reserves: 20M (10%)

**Parameters**:
- All tokens unlocked at TGE
- Paired with stablecoins (USDC, USDT) or native gas tokens (ETH, SOL)
- Initial price: [To be determined based on valuation]
- Liquidity locked for minimum 12 months

**Price Stability Mechanisms**:
- Deep liquidity pools to reduce slippage
- Market making partnerships for active management
- Treasury intervention protocol for extreme volatility

---

#### 3. Ecosystem Fund (20% - 200M tokens)

**Purpose**: Incentivize ecosystem growth, partnerships, and platform development

**Use Cases**:
- Grant program for developers: 80M (40%)
- Partnership incentives: 60M (30%)
- Hackathons and education: 30M (15%)
- Bug bounties: 20M (10%)
- Marketing campaigns: 10M (5%)

**Vesting**: 
- 36-month linear vesting
- 6-month cliff
- Governed by multi-signature wallet (3-of-5)

**Governance**:
- Quarterly allocation reviews
- Community input on grant recipients
- Transparent reporting on ecosystem spend
- KPI-driven performance metrics

---

#### 4. Team & Advisors (15% - 150M tokens)

**Purpose**: Align long-term incentives of core team and strategic advisors

**Allocation**:
- Core team (founders, early employees): 120M (80%)
- Advisors and strategic consultants: 30M (20%)

**Vesting**: 
- 24-month linear vesting
- 12-month cliff (no tokens until month 12)
- Accelerated vesting on acquisition (single-trigger)

**Clawback Provisions**:
- Forfeiture on voluntary departure before cliff
- Pro-rata vesting on termination for cause
- Full vesting protection on acquisition or IPO

**Team Size Assumptions**:
- 5-10 team members at TGE
- Scaling to 30-50 within 24 months
- Reserve allocation for future hires

---

#### 5. Treasury & Operations (10% - 100M tokens)

**Purpose**: Fund ongoing operations, market making, and strategic initiatives

**Use Cases**:
- Operational expenses: 40M (40%)
- Market making and liquidity: 30M (30%)
- Strategic acquisitions: 20M (20%)
- Emergency reserves: 10M (10%)

**Vesting**: 
- 24-month linear vesting
- 6-month cliff
- Multi-signature control (5-of-7 including community members)

**Financial Controls**:
- Monthly budget approval by board
- Quarterly financial reporting
- Annual audit by independent firm
- Transparent on-chain treasury tracking

---

#### 6. Strategic Partners (5% - 50M tokens)

**Purpose**: Secure critical partnerships and integrations

**Potential Partners**:
- Blockchain ecosystems (Ethereum, Solana, etc.)
- Compliance providers (Chainalysis, Elliptic)
- Infrastructure partners (Alchemy, Infura)
- Major exchanges (Coinbase, Binance)
- Institutional investors

**Vesting**: 
- 18-month linear vesting
- 6-month cliff
- Performance-based unlocks tied to milestones

**Criteria**:
- Strategic value to platform
- Non-financial contributions (integrations, visibility)
- Long-term commitment and alignment

---

#### 7. Private Sale (5% - 50M tokens)

**Purpose**: Raise initial capital for development and launch

**Terms** (Example):
- Token price: $0.01 per token
- Valuation: $10M fully diluted
- Raise amount: $500,000
- Minimum investment: $25,000
- Maximum allocation per investor: 10M tokens

**Vesting**: 
- 12-month linear vesting
- 3-month cliff
- No transfer restrictions post-vesting

**Investor Rights**:
- Information rights (quarterly updates)
- Pro-rata rights in follow-on rounds
- Board observer seat for major investors
- Standard protective provisions

---

## Vesting Summary

### Vesting Schedule Visualization

```
Month:   0    6    12   18   24   30   36
         |====|====|====|====|====|====|
TGE      20%
Airdrop  ▓▓▓▓▓▓░░░░
Liquidity▓▓▓▓▓▓▓▓▓▓
Ecosystem          ░░░░░░░░░░░░░░░░░░▓▓
Team                    ░░░░░░░░░░▓▓▓▓
Treasury               ░░░░▓▓▓▓▓▓▓▓
Partners               ░░░░▓▓▓▓▓▓
Private           ░░░▓▓▓▓▓▓

Legend: ░ = Cliff period, ▓ = Vesting/unlocked
```

### Cliff Periods Explained

**Cliff**: A period during which no tokens vest. After the cliff, vesting begins according to schedule.

- **No Cliff**: Airdrop, liquidity - immediate utility
- **3 Months**: Private sale - minimal lock-up for early capital
- **6 Months**: Ecosystem, treasury, partners - medium-term alignment
- **12 Months**: Team - long-term commitment and alignment

---

## Token Utility

### Platform Functions

1. **Payment for Services**
   - Token launch fees (optional discount for paying in native token)
   - NFT marketplace fees
   - Subscription services
   - Premium features and white-label access

2. **Staking and Rewards**
   - Stake tokens to earn platform fee revenue share
   - NFT staking for boosted rewards
   - Liquidity provider incentives
   - Long-term holder bonuses

3. **Governance**
   - Vote on protocol parameters (fees, features, partnerships)
   - Propose and vote on ecosystem grants
   - Treasury allocation decisions
   - Emergency response and upgrades

4. **Access and Discounts**
   - Tier-based access to platform features
   - Fee discounts (10-50% based on holdings)
   - Priority support and services
   - Exclusive launches and early access

---

## Economic Mechanisms

### Fee Structure

**Platform Fees** (Baseline):
- Token launch: 0.5% of supply or $499 flat fee
- NFT marketplace: 2.5% transaction fee
- Subscription services: $99-$499/month
- Professional services: Hourly or project-based

**Token Holder Discounts**:
- Bronze (1,000+ tokens): 10% discount
- Silver (10,000+ tokens): 25% discount
- Gold (100,000+ tokens): 50% discount
- Platinum (1,000,000+ tokens): Free access + revenue share

### Burn Mechanisms

**Fee Burns**: 
- 25% of platform fees burned permanently
- Reduces total supply over time
- Creates deflationary pressure

**Buyback and Burn**:
- Quarterly buyback using 10% of platform revenue
- Tokens purchased on open market and burned
- Transparent reporting of burn transactions

**Maximum Burn Cap**: 
- Cannot reduce supply below 100M tokens (10% of original)
- Ensures minimum liquidity and functionality

### Reward Distribution

**Staking Rewards**:
- 50% of platform fees distributed to stakers
- Rewards calculated based on stake share
- Monthly distribution to minimize gas costs
- No lockup required but longer stakes earn bonus multipliers

**Liquidity Mining**:
- Additional token emissions to incentivize liquidity
- Declining emission schedule (halving every 6 months)
- Focus on stable pairs (USDC, USDT) to reduce IL
- Audited and fair farming contracts

---

## Compliance Considerations

### Securities Law Analysis

**Utility Token Characteristics**:
- Primary use: Access to platform services and governance
- Not marketed as investment
- Value derived from platform usage and network effects
- Decentralized distribution and governance

**Risk Mitigation**:
- No promises of profits or returns
- Avoid investment-focused marketing
- Functional utility from day one
- Decentralization roadmap

**Legal Disclaimer**: 
*Consult with legal counsel for jurisdiction-specific analysis. This framework does not constitute legal advice.*

### Tax Implications

**For Token Issuers**:
- Potential taxable income on token allocation
- Consult tax advisor on cost basis and recognition
- Reporting requirements vary by jurisdiction

**For Token Holders**:
- Airdrop receipt may be taxable event
- Capital gains on token appreciation
- Staking rewards typically taxable as income
- Track cost basis for accurate reporting

---

## Governance and Control

### Multi-Signature Treasury

**Configuration**:
- 5-of-7 multi-signature for treasury operations
- Signers: 3 team members, 2 community members, 2 advisors
- Time delays for large transactions (>1% of treasury)

**Powers**:
- Approve ecosystem grants
- Execute strategic initiatives
- Emergency pause functionality
- Upgrade proposals

### Community Governance

**Voting Power**:
- 1 token = 1 vote (linear)
- Delegation support for passive holders
- Quadratic voting for select decisions
- Reputation-weighted voting (future consideration)

**Proposal Process**:
1. Discussion phase (7 days minimum)
2. Formal proposal with executable code
3. Voting period (7 days)
4. Quorum requirement (10% of circulating supply)
5. Execution with time lock (48 hours)

---

## Performance Metrics and KPIs

### Token Health Metrics

- **Trading Volume**: Daily/weekly volume on DEXs
- **Liquidity Depth**: Total liquidity and price impact
- **Holder Distribution**: Concentration vs. decentralization
- **Circulating Supply**: Vested tokens in circulation
- **Market Cap**: Price × circulating supply

### Platform Metrics

- **Total Value Locked (TVL)**: Staked + LP tokens
- **Active Users**: Daily/monthly active addresses
- **Transaction Count**: Platform interactions
- **Revenue Generated**: Fees collected in USD equivalent
- **Token Burns**: Cumulative tokens removed from supply

### Target Milestones

| Metric | 6 Months | 12 Months | 24 Months |
|--------|----------|-----------|-----------|
| Market Cap | $50M | $150M | $500M |
| Holders | 10,000 | 50,000 | 200,000 |
| TVL | $10M | $50M | $200M |
| Daily Tx | 1,000 | 5,000 | 20,000 |

---

## Risk Factors

### Token-Specific Risks

- **Price Volatility**: Market conditions and speculation
- **Liquidity Risk**: Insufficient trading volume
- **Smart Contract Risk**: Vulnerabilities in token or staking contracts
- **Regulatory Risk**: Classification as security or regulatory restrictions

### Mitigation Strategies

- Deep initial liquidity and market making
- Multiple exchange listings
- Rigorous security audits
- Proactive regulatory engagement

*See [RISK_FACTORS.md](RISK_FACTORS.md) for comprehensive risk analysis*

---

## Appendix

### Token Contract Details

**EVM Implementation**:
- Standard: ERC-20 (OpenZeppelin base)
- Features: Pausable, burnable, snapshots (for airdrops)
- Upgradability: UUPS proxy pattern
- Admin: Multi-signature wallet

**Solana Implementation**:
- Standard: SPL Token
- Features: Mint authority (initially revoked), freeze authority (optional)
- Upgradability: Via program upgrades with governance

### Sample Vesting Contract

*See `/contracts/VestingVault.sol` for implementation reference*

### Historical Examples

**Reference Projects** (for learning, not endorsement):
- Uniswap (UNI): Community-focused distribution
- Compound (COMP): Governance and liquidity mining
- Aave (AAVE): Ecosystem fund model
- Synthetix (SNX): Aggressive staking rewards

### Frequently Asked Questions

**Q: Can more tokens be minted?**  
A: No, the supply is fixed at 1 billion with no mint authority.

**Q: What happens to unclaimed airdrops?**  
A: After 12 months, unclaimed tokens return to ecosystem fund.

**Q: How are staking rewards funded?**  
A: From platform fees (50%) and initial ecosystem allocation.

**Q: Can tokens be transferred during vesting?**  
A: No, vested tokens are locked in contract until vesting schedule completes.

---

**Disclaimer**: *This tokenomics document is a framework and subject to change based on legal, regulatory, and market considerations. Actual parameters will be determined prior to token generation event. This document does not constitute financial advice or an offer to sell securities.*

**Last Updated**: January 2025  
**Version**: 2.0 (Enhanced from v1.0)  
**Review Cycle**: Quarterly or as material changes occur
