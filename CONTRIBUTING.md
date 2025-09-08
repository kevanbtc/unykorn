# 🤝 Contributing to Unykorn

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Contributors](https://img.shields.io/github/contributors/kevanbtc/unykorn)](https://github.com/kevanbtc/unykorn/graphs/contributors)

We welcome contributions to the Unykorn ecosystem! This guide will help you get started with contributing to our cross-chain token launch factory.

## 📖 Table of Contents

- [🚀 Getting Started](#-getting-started)
- [🏗️ Development Setup](#️-development-setup)
- [📋 Contribution Guidelines](#-contribution-guidelines)
- [🔄 Pull Request Process](#-pull-request-process)
- [🧪 Testing Requirements](#-testing-requirements)
- [📝 Code Style](#-code-style)
- [🔒 Security Guidelines](#-security-guidelines)
- [📚 Documentation Standards](#-documentation-standards)
- [🐛 Bug Reports](#-bug-reports)
- [💡 Feature Requests](#-feature-requests)

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Node.js 18+** - For JavaScript/TypeScript development
- **Git** - Version control
- **pnpm** (optional) - Package management (recommended over npm)
- **Docker** (optional) - For containerized development

### Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/unykorn.git
   cd unykorn
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or with pnpm
   pnpm install
   ```

3. **Set up environment**
   ```bash
   cp .env.template .env
   # Edit .env with your local configuration
   ```

4. **Verify setup**
   ```bash
   npm run compile
   npm run test
   ```

## 🏗️ Development Setup

### Repository Structure

```
unykorn/
├── apps/                   # Application services
│   ├── frontend/          # Next.js user interface
│   ├── backend/           # Express.js API server
│   ├── indexer/           # Blockchain event indexer
│   └── agents/            # Background automation
├── contracts/             # Smart contracts
├── cli/                   # Command line tools
├── docs/                  # Documentation
└── test/                  # Test suites
```

### Local Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the code style guidelines
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**
   ```bash
   npm run test
   npm run lint
   npm run type-check
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

## 📋 Contribution Guidelines

### Types of Contributions

We welcome several types of contributions:

#### 🐛 Bug Fixes
- Fix existing issues
- Improve error handling
- Performance optimizations

#### ✨ New Features
- Add new functionality
- Enhance existing features
- Integration improvements

#### 📚 Documentation
- API documentation
- Code comments
- Guides and tutorials

#### 🧪 Testing
- Unit tests
- Integration tests
- Performance tests

#### 🎨 UI/UX
- Design improvements
- Accessibility enhancements
- Mobile responsiveness

### Contribution Areas

| Area | Skills Needed | Difficulty |
|------|---------------|------------|
| **Smart Contracts** | Solidity, Security | Advanced |
| **Frontend** | React, TypeScript, Web3 | Intermediate |
| **Backend** | Node.js, PostgreSQL, APIs | Intermediate |
| **DevOps** | Docker, CI/CD, Monitoring | Advanced |
| **Documentation** | Technical Writing | Beginner |
| **Testing** | Jest, Hardhat, QA | Intermediate |

## 🔄 Pull Request Process

### Before Submitting

1. **Check for existing issues**
   - Search existing issues and PRs
   - Create an issue if none exists

2. **Follow the branching strategy**
   ```bash
   # Feature branches
   feature/add-new-marketplace-function
   
   # Bug fix branches
   fix/resolve-staking-calculation-error
   
   # Documentation branches
   docs/update-api-documentation
   ```

3. **Ensure quality**
   - All tests pass
   - Code is linted and formatted
   - Documentation is updated

### PR Requirements

Your pull request should include:

- [ ] **Clear description** of changes made
- [ ] **Reference to related issue** (if applicable)
- [ ] **Tests** covering new functionality
- [ ] **Documentation** updates for user-facing changes
- [ ] **Breaking change notes** (if applicable)

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Documentation
- [ ] README updated
- [ ] API docs updated
- [ ] Comments added to complex code

## Breaking Changes
None / List any breaking changes

## Screenshots (if applicable)
Add screenshots for UI changes
```

## 🧪 Testing Requirements

### Smart Contracts

```bash
# Run contract tests
npm run test

# Generate coverage report
npm run coverage

# Gas usage analysis
npm run test:gas
```

**Requirements:**
- Unit tests for all public functions
- Integration tests for contract interactions
- Gas optimization tests
- Security vulnerability tests

### Frontend Applications

```bash
# Run frontend tests
cd apps/frontend
npm run test

# E2E tests
npm run test:e2e
```

**Requirements:**
- Component unit tests
- Integration tests for Web3 interactions
- Accessibility tests
- Cross-browser compatibility

### Backend Services

```bash
# Run backend tests
cd apps/backend
npm run test

# Integration tests
npm run test:integration
```

**Requirements:**
- API endpoint tests
- Database integration tests
- Authentication/authorization tests
- Performance tests

## 📝 Code Style

### TypeScript/JavaScript

We use **ESLint** and **Prettier** for code formatting:

```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format
```

**Standards:**
- Use TypeScript for all new code
- Follow existing naming conventions
- Add JSDoc comments for public functions
- Use async/await over Promises

### Solidity

**Standards:**
- Follow Solidity style guide
- Use NatSpec documentation
- Optimize for gas efficiency
- Include comprehensive tests

```solidity
/**
 * @title NFTMarketplace
 * @dev Marketplace contract for trading NFTs with fees
 * @author Unykorn Team
 */
contract NFTMarketplace is 
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    /// @notice Emitted when an NFT is listed for sale
    event ListingCreated(
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
}
```

### Commit Messages

Follow **Conventional Commits** specification:

```bash
# Format: type(scope): description
feat(marketplace): add batch listing functionality
fix(staking): resolve reward calculation error
docs(api): update endpoint documentation
test(contracts): add marketplace integration tests
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `test` - Adding tests
- `refactor` - Code refactoring
- `perf` - Performance improvements

## 🔒 Security Guidelines

### Smart Contract Security

- **Use OpenZeppelin** contracts where possible
- **Implement access controls** for sensitive functions
- **Add reentrancy guards** where needed
- **Validate all inputs** thoroughly
- **Follow checks-effects-interactions** pattern

### API Security

- **Validate all inputs** server-side
- **Use parameterized queries** to prevent SQL injection
- **Implement rate limiting** on endpoints
- **Sanitize user-generated content**
- **Use HTTPS** for all communications

### Reporting Security Issues

**Do not open public issues for security vulnerabilities.**

Instead, email security@unykorn.com with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact assessment
- Suggested fix (if known)

## 📚 Documentation Standards

### Code Documentation

- **JSDoc** for TypeScript/JavaScript functions
- **NatSpec** for Solidity contracts
- **README files** for each package/directory
- **Inline comments** for complex logic

### API Documentation

- **OpenAPI** specifications for REST APIs
- **GraphQL** schema documentation
- **Example requests/responses**
- **Error code descriptions**

### User Documentation

- **Setup guides** for new contributors
- **Usage examples** for CLI tools
- **Deployment instructions**
- **Troubleshooting guides**

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment details** (OS, Node version, etc.)
2. **Steps to reproduce** the issue
3. **Expected behavior**
4. **Actual behavior**
5. **Error messages** or logs
6. **Screenshots** (if applicable)

### Bug Report Template

```markdown
**Environment:**
- OS: [e.g., macOS 12.0]
- Node.js: [e.g., 18.0.0]
- npm: [e.g., 8.0.0]

**Steps to Reproduce:**
1. Step one
2. Step two
3. See error

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Error Messages:**
```
Paste error messages here
```

**Additional Context:**
Any other relevant information
```

## 💡 Feature Requests

Before submitting a feature request:

1. **Check existing issues** for similar requests
2. **Consider the scope** - does it fit the project goals?
3. **Provide use cases** and examples
4. **Suggest implementation** approaches (optional)

### Feature Request Template

```markdown
**Problem Statement:**
What problem does this solve?

**Proposed Solution:**
How should this be implemented?

**Alternatives Considered:**
What other approaches were considered?

**Additional Context:**
Mockups, examples, etc.
```

## 📞 Getting Help

- **Discord:** [Join our community](https://discord.gg/unykorn)
- **GitHub Discussions:** Ask questions and share ideas
- **Documentation:** Check the [docs/](docs/) directory
- **Email:** Contact team@unykorn.com for direct support

## 🎉 Recognition

Contributors will be:
- Listed in the project contributors
- Mentioned in release notes
- Eligible for community rewards
- Invited to special contributor events

Thank you for contributing to Unykorn! 🦄