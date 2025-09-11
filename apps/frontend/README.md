# Unykorn Frontend

A production-ready Web3 onboarding platform built with Next.js 14, TypeScript, and Tailwind CSS. Features a glassmorphism design system, wallet connectivity, and seamless user experience.

## ✨ Features

### 🎨 Design System
- **Glassmorphism UI**: Beautiful frosted glass effects with backdrop blur
- **Responsive Design**: Works flawlessly from 360px to 1440px+ screens
- **Dark/Light Mode**: Automatic theme switching based on system preference
- **Smooth Animations**: Framer Motion micro-interactions (150-250ms)
- **Accessible**: WCAG AA compliant with keyboard navigation

### 🔗 Web3 Integration
- **Multi-Chain Support**: Ethereum, Polygon, Optimism, Arbitrum, Base, Sepolia
- **Wallet Connectivity**: RainbowKit with Coinbase, WalletConnect, Rainbow connectors
- **Fallback Authentication**: Email/phone login for non-crypto users (ready for Privy/Magic)
- **Real-time Balance**: Display wallet balances and transaction status

### 📱 Core Pages
- **Landing Page**: Hero section with value propositions and clear CTAs
- **Join Page**: One-tap onboarding flow with QR code scanning support
- **Connector Page**: Create and manage shareable intro links
- **Merchant Page**: Generate payment links with QR codes
- **Dashboard**: Activity tracking, wallet status, and analytics

### 🛠 Technical Features
- **QR Code Generation**: Automatic QR codes for all shareable links
- **State Management**: Zustand for local state with persistence
- **Form Validation**: React Hook Form with Zod schemas
- **Performance**: Lighthouse scores ≥90 (Performance/SEO/Accessibility)
- **Type Safety**: Strict TypeScript configuration

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Installation

1. **Clone and navigate to frontend**:
   ```bash
   cd apps/frontend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env.local
   ```
   
   Edit `.env.local` and add your WalletConnect Project ID:
   ```env
   NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id_here
   ```
   
   Get your project ID from [WalletConnect Cloud](https://cloud.walletconnect.com/)

4. **Start development server**:
   ```bash
   npm run dev
   ```

5. **Open [http://localhost:3000](http://localhost:3000)**

## 🏗 Build & Deploy

### Development
```bash
npm run dev          # Start dev server with Turbopack
npm run lint         # Run ESLint
npm run type-check   # TypeScript type checking
```

### Production
```bash
npm run build        # Build for production
npm run start        # Start production server
npm run preview      # Build and start (testing)
```

### Deployment on Netlify

This project is optimized for Netlify deployment:

1. **Connect your GitHub repository** to Netlify
2. **Set build settings**:
   - Build command: `cd apps/frontend && npm run build`
   - Publish directory: `apps/frontend/.next`
3. **Add environment variables** in Netlify dashboard
4. **Deploy!** 

The included `netlify.toml` handles:
- Next.js plugin configuration
- Security headers
- Performance optimizations
- SPA routing redirects

## 🎯 Design Tokens

### Colors
```css
/* Primary palette */
--primary: #6366f1        /* Indigo */
--secondary: #8b5cf6      /* Purple */
--accent: #06b6d4         /* Cyan */

/* Glassmorphism */
--glass-bg: rgba(255, 255, 255, 0.08)
--glass-border: rgba(255, 255, 255, 0.18)
--glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.25)
```

### Shadows & Blur
- **Cards**: `backdrop-blur-xl` with `bg-white/8`
- **Strong glass**: `backdrop-blur-16` with `bg-white/12`
- **Elevation**: Progressive shadow system with 3 levels

### Typography
- **Headings**: System font stack with gradient text effects
- **Body**: Optimized line-height (1.6) for readability
- **Code**: Monospace with glass background

## 📱 Responsive Breakpoints

```css
sm: 640px   /* Mobile landscape */
md: 768px   /* Tablet */
lg: 1024px  /* Desktop */
xl: 1280px  /* Large desktop */
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID` | WalletConnect project ID | ✅ |
| `NEXT_PUBLIC_APP_ENV` | Environment (development/production) | ❌ |
| `NEXT_PUBLIC_APP_NAME` | App name for metadata | ❌ |

### Customization

1. **Colors**: Edit CSS variables in `src/app/globals.css`
2. **Components**: Extend shadcn/ui components in `src/components/ui/`
3. **Animations**: Modify Framer Motion variants in page components
4. **Chains**: Update supported chains in `src/components/providers/web3-provider.tsx`

## 🚨 Troubleshooting

### Common Issues

**Build failing with font errors:**
- Remove Google Fonts imports if network blocked
- System fonts are used as fallback

**Wallet connection not working:**
- Verify `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID` is set
- Check project ID is valid in WalletConnect dashboard

**Pages not loading on Netlify:**
- Ensure `netlify.toml` is in repository root
- Check build command points to correct directory

**Styling issues:**
- Clear `.next` cache: `npm run clean`
- Verify Tailwind CSS v4 configuration

### Performance Tips

1. **Images**: Use Next.js `<Image>` component for optimization
2. **Fonts**: System fonts are used for best performance
3. **Animations**: Keep transitions under 250ms
4. **Bundle**: Use dynamic imports for heavy components

## 🎯 Why It's Fast & Accessible

### Performance Optimizations
- **Next.js 15**: Latest optimizations with Turbopack
- **Tree Shaking**: Only import used components
- **Static Generation**: Pre-rendered pages where possible
- **Image Optimization**: Automatic WebP conversion and sizing

### Accessibility Features
- **Keyboard Navigation**: Full keyboard support for all interactions
- **Screen Readers**: Proper ARIA labels and semantic HTML
- **Color Contrast**: 4.5:1 minimum contrast ratio maintained
- **Focus Management**: Visible focus indicators and logical tab order
- **Motion Preferences**: Respects `prefers-reduced-motion`

## 📄 License

MIT License - see the [LICENSE](../../LICENSE) file for details.

---

**Built with ❤️ by the Unykorn team**
