'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  BarChart3, 
  Wallet, 
  Users, 
  CreditCard, 
  TrendingUp, 
  Activity,
  Copy,
  ExternalLink,
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import Navigation from '@/components/navigation'
import { useAppStore } from '@/lib/store'
import { useAccount, useBalance } from 'wagmi'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.3, ease: 'easeOut' }
}

const staggerChildren = {
  animate: {
    transition: {
      staggerChildren: 0.1
    }
  }
}

export default function DashboardPage() {
  const { activities, payLinks } = useAppStore()
  const { address, isConnected } = useAccount()
  const { data: balance } = useBalance({ address })
  const [copiedAddress, setCopiedAddress] = useState(false)

  // Mock analytics data
  const [analytics] = useState({
    totalEarnings: 1250.50,
    totalConnections: 23,
    totalPayments: 12,
    monthlyGrowth: 15.2
  })

  const copyAddress = async () => {
    if (address) {
      try {
        await navigator.clipboard.writeText(address)
        setCopiedAddress(true)
        setTimeout(() => setCopiedAddress(false), 2000)
      } catch (error) {
        console.error('Failed to copy address:', error)
      }
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="w-4 h-4 text-green-400" />
      case 'pending':
        return <Clock className="w-4 h-4 text-yellow-400" />
      case 'failed':
        return <XCircle className="w-4 h-4 text-red-400" />
      default:
        return <AlertCircle className="w-4 h-4 text-gray-400" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'text-green-400'
      case 'pending':
        return 'text-yellow-400'
      case 'failed':
        return 'text-red-400'
      default:
        return 'text-gray-400'
    }
  }

  return (
    <>
      <Navigation />
      
      <main className="min-h-screen pt-20">
        <div className="container mx-auto px-4 py-12">
          {/* Header */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="mb-12"
          >
            <div className="flex items-start justify-between">
              <div>
                <h1 className="text-4xl md:text-5xl font-bold mb-4">
                  Dashboard
                </h1>
                <p className="text-xl text-muted-foreground">
                  Track your Web3 activity and earnings
                </p>
              </div>
              
              {isConnected && (
                <Card className="glass">
                  <CardContent className="p-4">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                        <Wallet className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <p className="text-sm font-medium">Connected Wallet</p>
                        <div className="flex items-center space-x-2">
                          <code className="text-xs text-muted-foreground">
                            {address ? `${address.slice(0, 6)}...${address.slice(-4)}` : 'Not connected'}
                          </code>
                          {address && (
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={copyAddress}
                              className="h-6 px-2"
                            >
                              <Copy className="w-3 h-3" />
                              {copiedAddress && <span className="ml-1 text-xs">Copied!</span>}
                            </Button>
                          )}
                        </div>
                      </div>
                    </div>
                    {balance && (
                      <div className="mt-3 pt-3 border-t border-glass-border">
                        <p className="text-sm text-muted-foreground">Balance</p>
                        <p className="font-semibold">
                          {parseFloat(balance.formatted).toFixed(4)} {balance.symbol}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              )}
            </div>
          </motion.div>

          {/* Analytics Cards */}
          <motion.div
            variants={staggerChildren}
            initial="initial"
            animate="animate"
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12"
          >
            <motion.div variants={fadeInUp}>
              <Card className="glass">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Total Earnings</p>
                      <p className="text-2xl font-bold text-green-400">
                        ${analytics.totalEarnings.toFixed(2)}
                      </p>
                    </div>
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center">
                      <TrendingUp className="w-6 h-6 text-white" />
                    </div>
                  </div>
                  <div className="mt-4 flex items-center text-sm">
                    <TrendingUp className="w-4 h-4 text-green-400 mr-1" />
                    <span className="text-green-400">+{analytics.monthlyGrowth}%</span>
                    <span className="text-muted-foreground ml-2">this month</span>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={fadeInUp}>
              <Card className="glass">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Connections</p>
                      <p className="text-2xl font-bold">{analytics.totalConnections}</p>
                    </div>
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                      <Users className="w-6 h-6 text-white" />
                    </div>
                  </div>
                  <div className="mt-4 text-sm text-muted-foreground">
                    People you&apos;ve introduced
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={fadeInUp}>
              <Card className="glass">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Payments</p>
                      <p className="text-2xl font-bold">{analytics.totalPayments}</p>
                    </div>
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-accent to-secondary flex items-center justify-center">
                      <CreditCard className="w-6 h-6 text-white" />
                    </div>
                  </div>
                  <div className="mt-4 text-sm text-muted-foreground">
                    Successful transactions
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={fadeInUp}>
              <Card className="glass">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Pay Links</p>
                      <p className="text-2xl font-bold">{payLinks.length}</p>
                    </div>
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-secondary to-primary flex items-center justify-center">
                      <BarChart3 className="w-6 h-6 text-white" />
                    </div>
                  </div>
                  <div className="mt-4 text-sm text-muted-foreground">
                    Active payment links
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </motion.div>

          <div className="grid lg:grid-cols-3 gap-8">
            {/* Recent Activity */}
            <motion.div
              variants={fadeInUp}
              initial="initial"
              animate="animate"
              className="lg:col-span-2"
            >
              <Card className="glass h-fit">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <Activity className="w-5 h-5" />
                    <span>Recent Activity</span>
                  </CardTitle>
                  <CardDescription>
                    Your latest transactions and connections
                  </CardDescription>
                </CardHeader>
                
                <CardContent>
                  {activities.length === 0 ? (
                    <div className="text-center py-12">
                      <Activity className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                      <h3 className="text-lg font-medium mb-2">No activity yet</h3>
                      <p className="text-muted-foreground">
                        Start by creating intro links or pay links
                      </p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {activities.slice(0, 10).map((activity, index) => (
                        <motion.div
                          key={activity.id}
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: 0.05 * index }}
                          className="flex items-start space-x-3 p-3 glass rounded-lg"
                        >
                          <div className="flex-shrink-0 mt-1">
                            {getStatusIcon(activity.status)}
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium">
                              {activity.description}
                            </p>
                            <div className="flex items-center space-x-3 mt-1">
                              <p className="text-xs text-muted-foreground">
                                {activity.timestamp.toLocaleString()}
                              </p>
                              <span className={`text-xs capitalize ${getStatusColor(activity.status)}`}>
                                {activity.status}
                              </span>
                              {activity.amount && (
                                <span className="text-xs font-medium text-green-400">
                                  +${activity.amount}
                                </span>
                              )}
                            </div>
                          </div>
                        </motion.div>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </motion.div>

            {/* Quick Actions */}
            <motion.div
              variants={fadeInUp}
              initial="initial"
              animate="animate"
              transition={{ delay: 0.2 }}
              className="space-y-6"
            >
              <Card className="glass">
                <CardHeader>
                  <CardTitle>Quick Actions</CardTitle>
                  <CardDescription>
                    Common tasks and shortcuts
                  </CardDescription>
                </CardHeader>
                
                <CardContent className="space-y-3">
                  <Button variant="glass" className="w-full justify-start" asChild>
                    <a href="/connector">
                      <Users className="w-4 h-4 mr-3" />
                      Create Intro Link
                    </a>
                  </Button>
                  
                  <Button variant="glass" className="w-full justify-start" asChild>
                    <a href="/merchant">
                      <CreditCard className="w-4 h-4 mr-3" />
                      Create Pay Link
                    </a>
                  </Button>
                  
                  <Button variant="glass" className="w-full justify-start" asChild>
                    <a href="/join">
                      <ExternalLink className="w-4 h-4 mr-3" />
                      Share Join Link
                    </a>
                  </Button>
                </CardContent>
              </Card>

              {/* Wallet Info */}
              {!isConnected && (
                <Card className="glass">
                  <CardHeader>
                    <CardTitle className="text-sm">Connect Wallet</CardTitle>
                  </CardHeader>
                  
                  <CardContent>
                    <p className="text-sm text-muted-foreground mb-4">
                      Connect your wallet to access all features and track your earnings.
                    </p>
                    <Button variant="gradient" className="w-full">
                      <Wallet className="w-4 h-4 mr-2" />
                      Connect Wallet
                    </Button>
                  </CardContent>
                </Card>
              )}

              {/* Pay Links Summary */}
              {payLinks.length > 0 && (
                <Card className="glass">
                  <CardHeader>
                    <CardTitle className="text-sm">Active Pay Links</CardTitle>
                  </CardHeader>
                  
                  <CardContent>
                    <div className="space-y-3">
                      {payLinks.slice(0, 3).map((link) => (
                        <div key={link.id} className="flex items-center justify-between text-sm">
                          <div className="truncate flex-1">
                            <p className="font-medium truncate">{link.description}</p>
                            <p className="text-muted-foreground text-xs">
                              ${link.amount}
                            </p>
                          </div>
                          <Button size="sm" variant="ghost" asChild>
                            <a href="/merchant">
                              <ExternalLink className="w-3 h-3" />
                            </a>
                          </Button>
                        </div>
                      ))}
                      {payLinks.length > 3 && (
                        <Button variant="glass" size="sm" className="w-full" asChild>
                          <a href="/merchant">
                            View all {payLinks.length} links
                          </a>
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              )}
            </motion.div>
          </div>
        </div>
      </main>
    </>
  )
}