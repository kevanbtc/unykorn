import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import {
  mainnet,
  polygon,
  optimism,
  arbitrum,
  base,
  sepolia,
  polygonMumbai,
  optimismGoerli,
  arbitrumGoerli,
  baseGoerli
} from 'wagmi/chains'

export const config = getDefaultConfig({
  appName: 'Unykorn',
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || 'YOUR_PROJECT_ID',
  chains: [
    mainnet,
    polygon,
    optimism,
    arbitrum,
    base,
    // Testnets
    ...(process.env.NODE_ENV === 'development' ? [
      sepolia,
      polygonMumbai,
      optimismGoerli,
      arbitrumGoerli,
      baseGoerli
    ] : [])
  ],
  ssr: true,
})

export const SUPPORTED_CHAINS = {
  mainnet: {
    name: 'Ethereum',
    symbol: 'ETH',
    icon: '⟠'
  },
  polygon: {
    name: 'Polygon',
    symbol: 'MATIC',
    icon: '⬡'
  },
  optimism: {
    name: 'Optimism',
    symbol: 'OP',
    icon: '🔴'
  },
  arbitrum: {
    name: 'Arbitrum',
    symbol: 'ARB',
    icon: '🔵'
  },
  base: {
    name: 'Base',
    symbol: 'ETH',
    icon: '🔵'
  }
}