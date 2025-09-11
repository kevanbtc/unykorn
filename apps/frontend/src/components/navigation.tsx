'use client'

import Link from 'next/link'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import { Button } from '@/components/ui/button'
import { Wallet, Home, Users, CreditCard, BarChart3 } from 'lucide-react'

export default function Navigation() {
  return (
    <nav className="fixed top-0 w-full z-50 border-b border-glass-border glass">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2 group">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center group-hover:scale-110 transition-transform">
              <span className="text-white font-bold text-sm">U</span>
            </div>
            <span className="text-xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
              Unykorn
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-6">
            <Link href="/" className="flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors">
              <Home className="w-4 h-4" />
              <span>Home</span>
            </Link>
            <Link href="/join" className="flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors">
              <Users className="w-4 h-4" />
              <span>Join</span>
            </Link>
            <Link href="/connector" className="flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors">
              <Users className="w-4 h-4" />
              <span>Connect</span>
            </Link>
            <Link href="/merchant" className="flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors">
              <CreditCard className="w-4 h-4" />
              <span>Merchant</span>
            </Link>
            <Link href="/dashboard" className="flex items-center space-x-2 text-muted-foreground hover:text-foreground transition-colors">
              <BarChart3 className="w-4 h-4" />
              <span>Dashboard</span>
            </Link>
          </div>

          {/* Wallet Connect */}
          <div className="flex items-center space-x-4">
            <ConnectButton.Custom>
              {({
                account,
                chain,
                openAccountModal,
                openChainModal,
                openConnectModal,
                authenticationStatus,
                mounted,
              }) => {
                const ready = mounted && authenticationStatus !== 'loading'
                const connected =
                  ready &&
                  account &&
                  chain &&
                  (!authenticationStatus ||
                    authenticationStatus === 'authenticated')

                return (
                  <div
                    {...(!ready && {
                      'aria-hidden': true,
                      'style': {
                        opacity: 0,
                        pointerEvents: 'none',
                        userSelect: 'none',
                      },
                    })}
                  >
                    {(() => {
                      if (!connected) {
                        return (
                          <Button 
                            onClick={openConnectModal} 
                            variant="gradient"
                            className="flex items-center space-x-2"
                          >
                            <Wallet className="w-4 h-4" />
                            <span>Connect Wallet</span>
                          </Button>
                        )
                      }

                      if (chain.unsupported) {
                        return (
                          <Button 
                            onClick={openChainModal} 
                            variant="destructive"
                          >
                            Wrong network
                          </Button>
                        )
                      }

                      return (
                        <div className="flex items-center space-x-2">
                          <Button
                            onClick={openChainModal}
                            variant="glass"
                            size="sm"
                            className="flex items-center space-x-1"
                          >
                            {chain.hasIcon && (
                              <div
                                style={{
                                  background: chain.iconBackground,
                                  width: 16,
                                  height: 16,
                                  borderRadius: 999,
                                  overflow: 'hidden',
                                }}
                              >
                                {chain.iconUrl && (
                                  // eslint-disable-next-line @next/next/no-img-element
                                  <img
                                    alt={chain.name ?? 'Chain icon'}
                                    src={chain.iconUrl}
                                    style={{ width: 16, height: 16 }}
                                  />
                                )}
                              </div>
                            )}
                            <span className="text-xs">{chain.name}</span>
                          </Button>

                          <Button
                            onClick={openAccountModal}
                            variant="glass"
                            size="sm"
                            className="flex items-center space-x-2"
                          >
                            <Wallet className="w-4 h-4" />
                            <span className="text-xs">
                              {account.displayName}
                            </span>
                          </Button>
                        </div>
                      )
                    })()}
                  </div>
                )
              }}
            </ConnectButton.Custom>
          </div>
        </div>
      </div>
    </nav>
  )
}