'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'
import { ArrowRight, Zap, Users, CreditCard, Shield, QrCode, TrendingUp } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import Navigation from '@/components/navigation'

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

export default function Home() {
  return (
    <>
      <Navigation />
      
      <main className="min-h-screen pt-20">
        {/* Hero Section */}
        <section className="relative overflow-hidden py-20 lg:py-32">
          <div className="container mx-auto px-4">
            <motion.div 
              className="text-center max-w-4xl mx-auto"
              variants={staggerChildren}
              initial="initial"
              animate="animate"
            >
              <motion.div
                variants={fadeInUp}
                className="inline-flex items-center px-4 py-2 mb-6 glass rounded-full border border-glass-border"
              >
                <Zap className="w-4 h-4 mr-2 text-primary" />
                <span className="text-sm font-medium">Web3 Onboarding Made Simple</span>
              </motion.div>
              
              <motion.h1 
                variants={fadeInUp}
                className="text-4xl md:text-6xl lg:text-7xl font-bold mb-6 bg-gradient-to-r from-foreground via-primary to-accent bg-clip-text text-transparent leading-tight"
              >
                Turn time & intros 
                <br />
                into <span className="relative">
                  value
                  <motion.div
                    className="absolute -bottom-2 left-0 right-0 h-1 bg-gradient-to-r from-primary to-accent rounded-full"
                    initial={{ scaleX: 0 }}
                    animate={{ scaleX: 1 }}
                    transition={{ delay: 0.8, duration: 0.5 }}
                  />
                </span>
              </motion.h1>
              
              <motion.p 
                variants={fadeInUp}
                className="text-xl md:text-2xl text-muted-foreground mb-8 max-w-2xl mx-auto leading-relaxed"
              >
                Scan. Share. Get paid when real commerce happens. 
                The simplest way to onboard people into Web3.
              </motion.p>
              
              <motion.div 
                variants={fadeInUp}
                className="flex flex-col sm:flex-row gap-4 justify-center items-center"
              >
                <Button size="xl" variant="gradient" asChild className="min-w-[200px]">
                  <Link href="/join" className="flex items-center space-x-2">
                    <span>Join now</span>
                    <ArrowRight className="w-5 h-5" />
                  </Link>
                </Button>
                <Button size="xl" variant="glass" asChild className="min-w-[200px]">
                  <Link href="/connector">Share an intro</Link>
                </Button>
              </motion.div>
            </motion.div>
          </div>
          
          {/* Background decorations */}
          <div className="absolute top-1/4 left-10 w-32 h-32 bg-primary/10 rounded-full blur-3xl" />
          <div className="absolute bottom-1/4 right-10 w-48 h-48 bg-accent/10 rounded-full blur-3xl" />
        </section>

        {/* Features Section */}
        <section className="py-20 lg:py-32">
          <div className="container mx-auto px-4">
            <motion.div
              className="text-center mb-16"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
            >
              <h2 className="text-3xl md:text-5xl font-bold mb-4">
                Why choose Unykorn?
              </h2>
              <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
                Built for the next generation of Web3 users. Simple, secure, and accessible to everyone.
              </p>
            </motion.div>
            
            <motion.div 
              className="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
              variants={staggerChildren}
              initial="initial"
              whileInView="animate"
              viewport={{ once: true }}
            >
              <motion.div variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-accent flex items-center justify-center mb-4">
                      <QrCode className="w-6 h-6 text-white" />
                    </div>
                    <CardTitle>QR & Deep Links</CardTitle>
                    <CardDescription>
                      Generate QR codes and share links for instant onboarding via posters, NFC, or SMS.
                    </CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
              
              <motion.div variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-accent to-secondary flex items-center justify-center mb-4">
                      <Users className="w-6 h-6 text-white" />
                    </div>
                    <CardTitle>Easy Onboarding</CardTitle>
                    <CardDescription>
                      One-tap flow designed for older users. No complex crypto knowledge required.
                    </CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
              
              <motion.div variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-secondary to-primary flex items-center justify-center mb-4">
                      <CreditCard className="w-6 h-6 text-white" />
                    </div>
                    <CardTitle>Smart Payments</CardTitle>
                    <CardDescription>
                      Create payment links, track commerce, and get paid when real transactions happen.
                    </CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
              
              <motion.div variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-accent flex items-center justify-center mb-4">
                      <Shield className="w-6 h-6 text-white" />
                    </div>
                    <CardTitle>Web3 & Fallback</CardTitle>
                    <CardDescription>
                      RainbowKit wallet connect with email/phone fallback for non-crypto users.
                    </CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
              
              <motion.div variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-accent to-secondary flex items-center justify-center mb-4">
                      <TrendingUp className="w-6 h-6 text-white" />
                    </div>
                    <CardTitle>Track Performance</CardTitle>
                    <CardDescription>
                      Monitor wallet status, activity, and payouts with comprehensive analytics.
                    </CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
              
              <motion.div variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-secondary to-primary flex items-center justify-center mb-4">
                      <Zap className="w-6 h-6 text-white" />
                    </div>
                    <CardTitle>Lightning Fast</CardTitle>
                    <CardDescription>
                      Optimized for speed with Lighthouse scores ≥90. Production-ready performance.
                    </CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
            </motion.div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-20 lg:py-32">
          <div className="container mx-auto px-4">
            <motion.div 
              className="text-center max-w-3xl mx-auto"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
            >
              <Card className="glass-strong">
                <CardContent className="p-12">
                  <h2 className="text-3xl md:text-4xl font-bold mb-4">
                    Ready to get started?
                  </h2>
                  <p className="text-xl text-muted-foreground mb-8">
                    Join thousands of users who are already earning through meaningful connections.
                  </p>
                  <div className="flex flex-col sm:flex-row gap-4 justify-center">
                    <Button size="xl" variant="gradient" asChild>
                      <Link href="/join" className="flex items-center space-x-2">
                        <span>Join now</span>
                        <ArrowRight className="w-5 h-5" />
                      </Link>
                    </Button>
                    <Button size="xl" variant="glass" asChild>
                      <Link href="/merchant">Create a pay link</Link>
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-glass-border glass py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                  <span className="text-white font-bold text-sm">U</span>
                </div>
                <span className="text-xl font-bold">Unykorn</span>
              </div>
              <p className="text-muted-foreground">
                Turn time & intros into value. Web3 onboarding made simple.
              </p>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Product</h3>
              <ul className="space-y-2 text-muted-foreground">
                <li><Link href="/join" className="hover:text-foreground transition-colors">Join</Link></li>
                <li><Link href="/connector" className="hover:text-foreground transition-colors">Connect</Link></li>
                <li><Link href="/merchant" className="hover:text-foreground transition-colors">Merchant</Link></li>
                <li><Link href="/dashboard" className="hover:text-foreground transition-colors">Dashboard</Link></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Company</h3>
              <ul className="space-y-2 text-muted-foreground">
                <li><a href="#" className="hover:text-foreground transition-colors">About</a></li>
                <li><a href="#" className="hover:text-foreground transition-colors">Blog</a></li>
                <li><a href="#" className="hover:text-foreground transition-colors">Careers</a></li>
                <li><a href="#" className="hover:text-foreground transition-colors">Contact</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Legal</h3>
              <ul className="space-y-2 text-muted-foreground">
                <li><a href="#" className="hover:text-foreground transition-colors">Terms</a></li>
                <li><a href="#" className="hover:text-foreground transition-colors">Privacy</a></li>
                <li><a href="#" className="hover:text-foreground transition-colors">Disclosures</a></li>
                <li><a href="#" className="hover:text-foreground transition-colors">Compliance</a></li>
              </ul>
            </div>
          </div>
          
          <div className="mt-8 pt-8 border-t border-glass-border text-center text-muted-foreground">
            <p>&copy; 2024 Unykorn. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </>
  )
}
