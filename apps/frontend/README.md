# Unykorn Frontend

A production-ready Web3 platform built with Next.js 14, featuring glassmorphism design, wallet integration, and cross-chain support.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## ✨ Features

### 🎨 Design System
- **Glassmorphism UI** - Frosted glass components with depth and blur effects
- **Responsive Design** - Mobile-first approach supporting 360px to 1440px
- **Dark Mode** - Optimized for modern dark interfaces
- **Smooth Animations** - Framer Motion micro-interactions (150-250ms)
- **Accessibility** - WCAG AA compliant with keyboard navigation

### 🔗 Web3 Integration
- **RainbowKit + Wagmi** - Multi-wallet support (Coinbase, WalletConnect, Rainbow)
- **Cross-Chain** - Ethereum, Polygon, Arbitrum, Base, and more
- **Fallback Auth** - Email/phone login for non-crypto users
- **Wallet Connect** - Seamless onboarding experience

### 📱 Core Pages
- **Landing Page** - Hero section with value propositions and CTAs
- **Join Page** - One-tap onboarding with referral support
- **Connector Page** - Share intro links with QR code generation
- **Merchant Page** - Create payment links and QR codes
- **Dashboard** - Wallet status, earnings, and activity tracking

### 🛠️ Technical Features
- **QR Code Generation** - Instant QR codes for links and payments
- **Form Validation** - Zod + React Hook Form with TypeScript
- **State Management** - Zustand with persistence
- **Notifications** - Toast-style notifications system
- **Performance** - Optimized for Lighthouse ≥90 scores

## 🏗️ Architecture

```
src/
├── app/                    # Next.js App Router pages
│   ├── join/              # Join flow
│   ├── connector/         # Link sharing
│   ├── merchant/          # Payment links  
│   ├── dashboard/         # User dashboard
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Landing page
├── components/
│   ├── ui/                # Base UI components
│   ├── providers/         # Context providers
│   └── navigation.tsx     # Main navigation
├── lib/                   # Utilities and configs
│   ├── utils.ts          # Common utilities
│   ├── qr.ts             # QR code generation
│   └── web3.ts           # Web3 configuration
└── stores/               # Zustand stores
    └── app-store.ts      # Main application state
```

## 🎨 Design Tokens

### Glassmorphism Colors
```css
--glass-bg-light: rgba(255, 255, 255, 0.08)
--glass-bg-dark: rgba(255, 255, 255, 0.05)
--glass-border: rgba(255, 255, 255, 0.1)
--glass-blur: 20px
```

### Shadows
```css
--glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.25)
--glass-shadow-light: 0 8px 25px rgba(0, 0, 0, 0.1)
```

### Accent Colors
- **Primary**: #6366f1 (Indigo)
- **Secondary**: #8b5cf6 (Purple) 
- **Success**: #10b981 (Emerald)
- **Warning**: #f59e0b (Amber)
- **Error**: #ef4444 (Red)

## 🔧 Configuration

### Environment Variables

Create `.env.local` from `.env.example`:

```bash
# Web3 Configuration
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id

# Environment
NEXT_PUBLIC_ENV=development

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3001

# Feature Flags
NEXT_PUBLIC_ENABLE_TESTNETS=true
```

### Deployment

#### Netlify (Recommended)
The project includes `netlify.toml` configuration:

1. Connect your repository to Netlify
2. Build command: `cd apps/frontend && npm run build`
3. Publish directory: `apps/frontend/.next`

#### Vercel
```bash
vercel --prod
```

#### Static Export
```bash
npm run build
npm run export
```

## 🚀 Performance

### Optimization Features
- **Code Splitting** - Automatic route-based splitting
- **Image Optimization** - Next.js Image component with WebP/AVIF
- **Bundle Analysis** - Package optimization with tree shaking
- **Lazy Loading** - Components and routes loaded on demand

### Lighthouse Scores
- **Performance**: ≥90
- **Accessibility**: ≥90  
- **Best Practices**: ≥90
- **SEO**: ≥90

## 🔒 Security

### Headers
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`

### Content Security Policy
- Strict CSP for images and scripts
- Sandboxed SVG content

## 🐛 Troubleshooting

### Netlify 404 Issues
If you encounter 404 errors on Netlify:

1. **For SSR**: Ensure `@netlify/plugin-nextjs` is in `netlify.toml`
2. **For Static**: Add `_redirects` file with `/* /index.html 200`

### Build Errors
- Ensure Node.js version ≥18
- Clear `.next` and `node_modules` if needed
- Check environment variables

### Wallet Connection Issues
- Verify `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID`
- Check network connectivity
- Ensure HTTPS in production

---

Built with ❤️ for the future of Web3 onboarding.
