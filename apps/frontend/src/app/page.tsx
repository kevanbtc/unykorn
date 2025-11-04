'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'
import { ArrowRight, Zap, DollarSign, QrCode, Shield, Globe } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

const fadeInUp = {
  initial: { opacity: 0, y: 60 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.6 }
}

const stagger = {
  animate: {
    transition: {
      staggerChildren: 0.1
    }
  }
}

const features = [
  {
    icon: QrCode,
    title: "Scan & Share",
    description: "Generate QR codes for instant connections. Share intro links that actually work."
  },
  {
    icon: DollarSign,
    title: "Get Paid",
    description: "Earn when your connections lead to real commerce. Time and intros have value."
  },
  {
    icon: Shield,
    title: "Web3 Secured",
    description: "Wallet integration with email/phone fallback. Secure and accessible for everyone."
  },
  {
    icon: Globe,
    title: "Cross-Chain",
    description: "Works across multiple blockchains. Ethereum, Polygon, Arbitrum, and more."
  }
]

const stats = [
  { value: "10K+", label: "Active Users" },
  { value: "$2.5M", label: "Paid Out" },
  { value: "50K+", label: "Connections Made" },
  { value: "99.9%", label: "Uptime" }
]

export default function Home() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-900/20 via-purple-900/20 to-pink-900/20" />
        <div className="absolute inset-0">
          <div className="absolute top-20 left-20 w-72 h-72 bg-gradient-to-r from-indigo-500/20 to-purple-500/20 rounded-full blur-3xl animate-float" />
          <div className="absolute bottom-20 right-20 w-96 h-96 bg-gradient-to-r from-purple-500/20 to-pink-500/20 rounded-full blur-3xl animate-float" style={{ animationDelay: '2s' }} />
        </div>
        
        <div className="relative container mx-auto px-4 py-32">
          <motion.div
            className="text-center max-w-4xl mx-auto"
            variants={stagger}
            initial="initial"
            animate="animate"
          >
            <motion.h1
              className="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight"
              variants={fadeInUp}
            >
              Turn time & intros into{' '}
              <span className="bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
                value
              </span>
            </motion.h1>
            
            <motion.p
              className="text-xl md:text-2xl text-white/80 mb-12 leading-relaxed"
              variants={fadeInUp}
            >
              Scan. Share. Get paid when real commerce happens.
              <br />
              The future of Web3 onboarding is here.
            </motion.p>
            
            <motion.div
              className="flex flex-col sm:flex-row gap-4 justify-center"
              variants={fadeInUp}
            >
              <Button asChild size="xl" variant="primary">
                <Link href="/join">
                  Join Now
                  <ArrowRight className="ml-2 h-5 w-5" />
                </Link>
              </Button>
              
              <Button asChild size="xl" variant="outline">
                <Link href="/connector">
                  Share an Intro
                </Link>
              </Button>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-20 relative">
        <div className="container mx-auto px-4">
          <motion.div
            className="grid grid-cols-2 md:grid-cols-4 gap-8"
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            {stats.map((stat, statIndex) => (
              <motion.div
                key={stat.label}
                className="text-center"
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5, delay: statIndex * 0.1 }}
                viewport={{ once: true }}
              >
                <div className="text-3xl md:text-4xl font-bold text-white mb-2">
                  {stat.value}
                </div>
                <div className="text-white/60 font-medium">
                  {stat.label}
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 relative">
        <div className="container mx-auto px-4">
          <motion.div
            className="text-center mb-16"
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
              How it works
            </h2>
            <p className="text-xl text-white/70 max-w-2xl mx-auto">
              Simple, powerful tools for Web3 onboarding and rewards
            </p>
          </motion.div>

          <motion.div
            className="grid md:grid-cols-2 lg:grid-cols-4 gap-8"
            variants={stagger}
            initial="initial"
            whileInView="animate"
            viewport={{ once: true }}
          >
            {features.map((feature) => (
              <motion.div key={feature.title} variants={fadeInUp}>
                <Card className="h-full">
                  <CardHeader className="text-center">
                    <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-gradient-to-r from-indigo-500 to-purple-500 flex items-center justify-center">
                      <feature.icon className="h-8 w-8 text-white" />
                    </div>
                    <CardTitle className="text-xl">{feature.title}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <CardDescription className="text-center">
                      {feature.description}
                    </CardDescription>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 relative">
        <div className="container mx-auto px-4">
          <motion.div
            className="max-w-4xl mx-auto text-center"
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            <Card className="p-12">
              <CardContent className="space-y-8">
                <div>
                  <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                    Ready to get started?
                  </h2>
                  <p className="text-xl text-white/70">
                    Join thousands who are already earning from their connections
                  </p>
                </div>
                
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Button asChild size="xl" variant="primary">
                    <Link href="/join">
                      Join Now
                      <Zap className="ml-2 h-5 w-5" />
                    </Link>
                  </Button>
                  
                  <Button asChild size="xl" variant="secondary">
                    <Link href="/merchant">
                      Create Pay Link
                    </Link>
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 border-t border-white/10">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <Zap className="h-6 w-6 text-indigo-400" />
                <span className="text-xl font-bold text-white">Unykorn</span>
              </div>
              <p className="text-white/60">
                Turn time and intros into value with Web3.
              </p>
            </div>
            
            <div>
              <h3 className="font-semibold text-white mb-4">Product</h3>
              <ul className="space-y-2 text-white/60">
                <li><Link href="/join" className="hover:text-white transition-colors">Join</Link></li>
                <li><Link href="/connector" className="hover:text-white transition-colors">Connect</Link></li>
                <li><Link href="/merchant" className="hover:text-white transition-colors">Merchant</Link></li>
                <li><Link href="/dashboard" className="hover:text-white transition-colors">Dashboard</Link></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold text-white mb-4">Legal</h3>
              <ul className="space-y-2 text-white/60">
                <li><a href="#" className="hover:text-white transition-colors">Terms</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Privacy</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Disclosures</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold text-white mb-4">Connect</h3>
              <ul className="space-y-2 text-white/60">
                <li><a href="#" className="hover:text-white transition-colors">Twitter</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Discord</a></li>
                <li><a href="#" className="hover:text-white transition-colors">GitHub</a></li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-white/10 mt-8 pt-8 text-center text-white/60">
            <p>&copy; 2024 Unykorn. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}
