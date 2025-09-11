'use client'

import { useState, Suspense } from 'react'
import { motion } from 'framer-motion'
import { useRouter, useSearchParams } from 'next/navigation'
import { CheckCircle, Users, ArrowRight, QrCode } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import Navigation from '@/components/navigation'
import { useAppStore } from '@/lib/store'
import { useAccount } from 'wagmi'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.3, ease: 'easeOut' }
}

function JoinContent() {
  const [isJoining, setIsJoining] = useState(false)
  const [hasJoined, setHasJoined] = useState(false)
  const router = useRouter()
  const searchParams = useSearchParams()
  const { isConnected, address } = useAccount()
  const { addActivity, setUser } = useAppStore()
  
  const beaconId = searchParams.get('b')
  const referrer = searchParams.get('ref')

  const handleJoin = async () => {
    setIsJoining(true)
    
    // Simulate joining process
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // Add activity
    addActivity({
      type: 'join',
      description: `Joined via beacon ${beaconId || 'direct'}`,
      status: 'completed'
    })
    
    // Set user if connected
    if (isConnected && address) {
      setUser({
        id: address,
        walletAddress: address,
        createdAt: new Date()
      })
    }
    
    setIsJoining(false)
    setHasJoined(true)
    
    // Redirect to dashboard after success
    setTimeout(() => {
      router.push('/dashboard')
    }, 2000)
  }

  if (hasJoined) {
    return (
      <main className="min-h-screen pt-20 flex items-center justify-center">
        <div className="container mx-auto px-4">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5 }}
            className="text-center max-w-2xl mx-auto"
          >
            <Card className="glass-strong">
              <CardContent className="p-12">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
                  className="w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center"
                >
                  <CheckCircle className="w-10 h-10 text-white" />
                </motion.div>
                
                <h1 className="text-3xl md:text-4xl font-bold mb-4">
                  Welcome to Unykorn! 🎉
                </h1>
                
                <p className="text-xl text-muted-foreground mb-6">
                  You&apos;ve successfully joined the platform. 
                  {beaconId && ' Thanks for scanning that QR code!'}
                </p>
                
                <p className="text-muted-foreground mb-8">
                  Redirecting you to your dashboard in a moment...
                </p>
                
                <div className="flex justify-center">
                  <Button variant="gradient" onClick={() => router.push('/dashboard')}>
                    Go to Dashboard
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </main>
    )
  }

  return (
    <main className="min-h-screen pt-20 flex items-center justify-center">
      <div className="container mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center max-w-2xl mx-auto"
        >
          <Card className="glass-strong">
            <CardHeader className="text-center">
              <motion.div
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                className="w-16 h-16 mx-auto mb-6 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center"
              >
                <Users className="w-8 h-8 text-white" />
              </motion.div>
              
              <CardTitle className="text-3xl md:text-4xl font-bold mb-4">
                Join Unykorn
              </CardTitle>
              
              <CardDescription className="text-lg">
                {beaconId ? (
                  <>
                    You&apos;ve been invited to join via beacon <code className="glass px-2 py-1 rounded text-sm font-mono">{beaconId}</code>
                  </>
                ) : (
                  'Start your Web3 journey with a simple one-tap setup'
                )}
              </CardDescription>
            </CardHeader>
            
            <CardContent className="space-y-6">
              {beaconId && (
                <motion.div
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.1 }}
                  className="glass p-4 rounded-xl flex items-center space-x-3"
                >
                  <QrCode className="w-5 h-5 text-primary" />
                  <span className="text-sm">
                    Scanned from: {referrer || 'QR Code'}
                  </span>
                </motion.div>
              )}
              
              <motion.div
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
                className="space-y-4"
              >
                <h3 className="text-xl font-semibold">What happens next?</h3>
                <div className="text-left space-y-3">
                  <div className="flex items-start space-x-3">
                    <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-xs font-bold text-primary">1</span>
                    </div>
                    <div>
                      <p className="font-medium">One-tap setup</p>
                      <p className="text-sm text-muted-foreground">Connect your wallet or use email/phone</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start space-x-3">
                    <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-xs font-bold text-primary">2</span>
                    </div>
                    <div>
                      <p className="font-medium">Start earning</p>
                      <p className="text-sm text-muted-foreground">Share intros and get paid when commerce happens</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start space-x-3">
                    <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-xs font-bold text-primary">3</span>
                    </div>
                    <div>
                      <p className="font-medium">Track progress</p>
                      <p className="text-sm text-muted-foreground">Monitor your activity and payouts in your dashboard</p>
                    </div>
                  </div>
                </div>
              </motion.div>
              
              <motion.div
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.3 }}
                className="pt-4"
              >
                <Button
                  size="xl"
                  variant="gradient"
                  onClick={handleJoin}
                  disabled={isJoining}
                  className="w-full flex items-center justify-center space-x-2"
                >
                  {isJoining ? (
                    <>
                      <div className="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                      <span>Joining...</span>
                    </>
                  ) : (
                    <>
                      <span>Join now</span>
                      <ArrowRight className="w-5 h-5" />
                    </>
                  )}
                </Button>
                
                {!isConnected && (
                  <p className="text-xs text-muted-foreground mt-2">
                    Tip: Connect your wallet first for the best experience
                  </p>
                )}
              </motion.div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </main>
  )
}

export default function JoinPage() {
  return (
    <>
      <Navigation />
      <Suspense fallback={
        <main className="min-h-screen pt-20 flex items-center justify-center">
          <div className="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full animate-spin" />
        </main>
      }>
        <JoinContent />
      </Suspense>
    </>
  )
}