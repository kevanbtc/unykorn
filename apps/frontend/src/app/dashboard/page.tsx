'use client'

import { motion } from 'framer-motion'
import { useAccount } from 'wagmi'
import { Wallet, Activity, TrendingUp, Users, DollarSign, Copy, ExternalLink } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useAppStore } from '@/stores/app-store'
import { formatAddress } from '@/lib/utils'

const mockEarnings = [
  { type: 'Referral Bonus', amount: 25.50, date: '2024-01-15', status: 'completed' },
  { type: 'Connection Fee', amount: 12.00, date: '2024-01-14', status: 'completed' },
  { type: 'Merchant Commission', amount: 45.30, date: '2024-01-13', status: 'pending' },
  { type: 'Intro Reward', amount: 8.75, date: '2024-01-12', status: 'completed' }
]

export default function DashboardPage() {
  const { address, isConnected } = useAccount()
  const { activities, payLinks, addNotification } = useAppStore()

  const totalEarnings = mockEarnings.reduce((sum, earning) => 
    earning.status === 'completed' ? sum + earning.amount : sum, 0
  )

  const pendingEarnings = mockEarnings.reduce((sum, earning) => 
    earning.status === 'pending' ? sum + earning.amount : sum, 0
  )

  const copyAddress = async () => {
    if (!address) return
    
    try {
      await navigator.clipboard.writeText(address)
      addNotification({
        type: 'success',
        title: 'Copied!',
        message: 'Wallet address copied to clipboard.'
      })
    } catch (error) {
      console.error('Failed to copy:', error)
    }
  }

  return (
    <div className="min-h-screen py-12 px-4">
      <div className="max-w-6xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-4xl font-bold text-white mb-2">Dashboard</h1>
          <p className="text-white/70">Track your earnings, connections, and activity</p>
        </motion.div>

        {/* Wallet Status */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mb-8"
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Wallet className="h-5 w-5 text-indigo-400" />
                Wallet Status
              </CardTitle>
            </CardHeader>
            <CardContent>
              {isConnected ? (
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-white/60 mb-1">Connected Wallet</p>
                    <p className="font-mono text-white">{formatAddress(address || '')}</p>
                  </div>
                  <div className="flex gap-2">
                    <Button onClick={copyAddress} variant="outline" size="sm">
                      <Copy className="h-4 w-4 mr-2" />
                      Copy
                    </Button>
                    <Button asChild variant="outline" size="sm">
                      <a 
                        href={`https://etherscan.io/address/${address}`}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <ExternalLink className="h-4 w-4 mr-2" />
                        View
                      </a>
                    </Button>
                  </div>
                </div>
              ) : (
                <div className="text-center py-4">
                  <p className="text-white/60 mb-4">Connect your wallet to see your dashboard</p>
                  <Button variant="primary">Connect Wallet</Button>
                </div>
              )}
            </CardContent>
          </Card>
        </motion.div>

        {/* Stats Grid */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8"
        >
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-white/60">Total Earned</p>
                  <p className="text-2xl font-bold text-white">${totalEarnings.toFixed(2)}</p>
                </div>
                <DollarSign className="h-8 w-8 text-green-400" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-white/60">Pending</p>
                  <p className="text-2xl font-bold text-white">${pendingEarnings.toFixed(2)}</p>
                </div>
                <TrendingUp className="h-8 w-8 text-yellow-400" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-white/60">Connections</p>
                  <p className="text-2xl font-bold text-white">{activities.filter(a => a.type === 'connect').length}</p>
                </div>
                <Users className="h-8 w-8 text-blue-400" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-white/60">Pay Links</p>
                  <p className="text-2xl font-bold text-white">{payLinks.length}</p>
                </div>
                <Activity className="h-8 w-8 text-purple-400" />
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <div className="grid lg:grid-cols-2 gap-8">
          {/* Recent Earnings */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Recent Earnings</CardTitle>
                <CardDescription>Your latest payouts and pending rewards</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {mockEarnings.map((earning, index) => (
                    <div key={index} className="flex items-center justify-between p-3 rounded-lg glass-dark">
                      <div>
                        <p className="font-medium text-white">{earning.type}</p>
                        <p className="text-sm text-white/60">{earning.date}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-bold text-white">${earning.amount}</p>
                        <span className={`inline-block px-2 py-1 rounded text-xs ${
                          earning.status === 'completed' 
                            ? 'bg-green-500/20 text-green-400' 
                            : 'bg-yellow-500/20 text-yellow-400'
                        }`}>
                          {earning.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Recent Activity */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
                <CardDescription>Your latest actions on the platform</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {activities.length === 0 ? (
                    <div className="text-center py-8 text-white/50">
                      <Activity className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>No recent activity</p>
                      <p className="text-sm">Start by creating a connection or payment link</p>
                    </div>
                  ) : (
                    activities.slice(0, 5).map((activity) => (
                      <div key={activity.id} className="flex items-start gap-3 p-3 rounded-lg glass-dark">
                        <div className={`w-2 h-2 rounded-full mt-2 flex-shrink-0 ${
                          activity.status === 'completed' ? 'bg-green-400' : 
                          activity.status === 'pending' ? 'bg-yellow-400' : 'bg-red-400'
                        }`} />
                        <div className="flex-1 min-w-0">
                          <p className="text-white text-sm">{activity.description}</p>
                          <p className="text-white/60 text-xs">
                            {activity.timestamp.toLocaleDateString()} at {activity.timestamp.toLocaleTimeString()}
                          </p>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Quick Actions */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="mt-8"
        >
          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
              <CardDescription>Common tasks to grow your earnings</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid md:grid-cols-3 gap-4">
                <Button asChild variant="primary" size="lg" className="h-auto p-6 flex-col">
                  <a href="/connector">
                    <Users className="h-8 w-8 mb-2" />
                    <span className="text-base font-semibold">Share Intro Link</span>
                    <span className="text-sm opacity-80">Connect new members</span>
                  </a>
                </Button>
                
                <Button asChild variant="secondary" size="lg" className="h-auto p-6 flex-col">
                  <a href="/merchant">
                    <DollarSign className="h-8 w-8 mb-2" />
                    <span className="text-base font-semibold">Create Pay Link</span>
                    <span className="text-sm opacity-80">Generate payment QR</span>
                  </a>
                </Button>
                
                <Button asChild variant="outline" size="lg" className="h-auto p-6 flex-col">
                  <a href="/join">
                    <TrendingUp className="h-8 w-8 mb-2" />
                    <span className="text-base font-semibold">Join Community</span>
                    <span className="text-sm opacity-80">Expand your network</span>
                  </a>
                </Button>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  )
}