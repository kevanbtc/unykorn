'use client'

import { useState, Suspense } from 'react'
import { motion } from 'framer-motion'
import { useSearchParams } from 'next/navigation'
import { Check, Zap, Gift, Users } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useAppStore } from '@/stores/app-store'

const benefits = [
  "Earn from successful connections",
  "Access to exclusive opportunities", 
  "Web3 wallet integration",
  "QR code sharing tools",
  "Cross-chain compatibility"
]

function JoinPageContent() {
  const [isJoining, setIsJoining] = useState(false)
  const [hasJoined, setHasJoined] = useState(false)
  const searchParams = useSearchParams()
  const beaconId = searchParams.get('b')
  const { addActivity, addNotification } = useAppStore()

  const handleJoin = async () => {
    setIsJoining(true)
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Add activity
    addActivity({
      type: 'join',
      description: beaconId ? `Joined via beacon ${beaconId}` : 'Joined Unykorn platform',
      status: 'completed'
    })

    // Add notification
    addNotification({
      type: 'success',
      title: 'Welcome to Unykorn!',
      message: 'You have successfully joined the platform.'
    })

    setHasJoined(true)
    setIsJoining(false)
  }

  if (hasJoined) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="max-w-lg w-full"
        >
          <Card className="text-center p-8">
            <CardContent className="space-y-6">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2, type: "spring" }}
                className="w-16 h-16 mx-auto rounded-full bg-green-500 flex items-center justify-center"
              >
                <Check className="h-8 w-8 text-white" />
              </motion.div>
              
              <div>
                <h1 className="text-3xl font-bold text-white mb-2">Welcome aboard!</h1>
                <p className="text-white/70">
                  You&apos;re now part of the Unykorn community. Start earning from your connections today.
                </p>
              </div>

              <div className="flex flex-col sm:flex-row gap-3">
                <Button asChild size="lg" variant="primary" className="flex-1">
                  <a href="/dashboard">Go to Dashboard</a>
                </Button>
                <Button asChild size="lg" variant="outline" className="flex-1">
                  <a href="/connector">Share an Intro</a>
                </Button>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="max-w-4xl w-full">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <h1 className="text-4xl md:text-6xl font-bold text-white mb-6">
            Join the future of{' '}
            <span className="bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
              connections
            </span>
          </h1>
          <p className="text-xl text-white/80 max-w-2xl mx-auto">
            {beaconId 
              ? "You've been invited to join Unykorn! Start earning from meaningful connections."
              : "Start earning from your network. Simple, secure, and rewarding."
            }
          </p>
          {beaconId && (
            <div className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-lg glass">
              <Gift className="h-4 w-4 text-yellow-400" />
              <span className="text-white text-sm">Referral Code: {beaconId}</span>
            </div>
          )}
        </motion.div>

        <div className="grid md:grid-cols-2 gap-8 items-center">
          {/* Benefits Card */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Users className="h-6 w-6 text-indigo-400" />
                  Member Benefits
                </CardTitle>
                <CardDescription>
                  What you get when you join Unykorn
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className="space-y-3">
                  {benefits.map((benefit, index) => (
                    <motion.li
                      key={benefit}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.3 + index * 0.1 }}
                      className="flex items-center gap-3"
                    >
                      <Check className="h-5 w-5 text-green-400 flex-shrink-0" />
                      <span className="text-white/90">{benefit}</span>
                    </motion.li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          </motion.div>

          {/* Join Action Card */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
          >
            <Card>
              <CardHeader className="text-center">
                <CardTitle className="text-2xl">Ready to start?</CardTitle>
                <CardDescription>
                  Join thousands earning from their connections
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="text-center">
                  <div className="text-sm text-white/60 mb-4">
                    One-tap to join. It&apos;s that simple.
                  </div>
                  
                  <Button
                    onClick={handleJoin}
                    disabled={isJoining}
                    size="xl"
                    variant="primary"
                    className="w-full"
                  >
                    {isJoining ? (
                      <>
                        <motion.div
                          animate={{ rotate: 360 }}
                          transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                          className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full mr-2"
                        />
                        Joining...
                      </>
                    ) : (
                      <>
                        <Zap className="mr-2 h-5 w-5" />
                        Join Now
                      </>
                    )}
                  </Button>
                </div>

                <div className="text-xs text-white/50 text-center">
                  By joining, you agree to our{' '}
                  <a href="#" className="text-indigo-400 hover:text-indigo-300">Terms</a>
                  {' '}and{' '}
                  <a href="#" className="text-indigo-400 hover:text-indigo-300">Privacy Policy</a>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    </div>
  )
}

export default function JoinPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-white">Loading...</div>
      </div>
    }>
      <JoinPageContent />
    </Suspense>
  )
}