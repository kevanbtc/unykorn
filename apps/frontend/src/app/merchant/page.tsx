'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { CreditCard, Copy, Share2, ExternalLink, Plus, DollarSign, QrCode, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import Navigation from '@/components/navigation'
import { generatePayUrl, generateQRCode } from '@/lib/qr'
import { useAppStore } from '@/lib/store'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.3, ease: 'easeOut' }
}

interface PayLink {
  id: string
  amount: number
  description: string
  merchantId: string
  url: string
  qrCode?: string
  createdAt: Date
  expiresAt?: Date
  uses?: number
  pointOfInterest?: string
}

export default function MerchantPage() {
  const [payLinks, setPayLinks] = useState<PayLink[]>([])
  const [isCreating, setIsCreating] = useState(false)
  const [formData, setFormData] = useState({
    amount: '',
    description: '',
    pointOfInterest: ''
  })
  const [copiedLinkId, setCopiedLinkId] = useState<string | null>(null)
  const { addPayLink, addActivity, payLinks: storePayLinks } = useAppStore()

  useEffect(() => {
    // Set initial pay links from store
    if (storePayLinks.length > 0) {
      setPayLinks(storePayLinks)
    } else {
      // Mock existing pay links
      setPayLinks([
        {
          id: 'pay-001',
          amount: 50,
          description: 'Coffee & Consultation',
          merchantId: 'merchant-123',
          url: generatePayUrl('50', 'merchant-123', 'coffee'),
          createdAt: new Date('2024-01-15'),
          expiresAt: new Date('2024-02-15'),
          uses: 3
        },
        {
          id: 'pay-002',
          amount: 200,
          description: 'Web3 Workshop Ticket',
          merchantId: 'merchant-123',
          url: generatePayUrl('200', 'merchant-123', 'workshop'),
          createdAt: new Date('2024-01-12'),
          uses: 12
        }
      ])
    }
  }, [storePayLinks])

  const createPayLink = async () => {
    if (!formData.amount || !formData.description) return
    
    setIsCreating(true)
    
    const merchantId = `merchant-${Date.now()}`
    const url = generatePayUrl(formData.amount, merchantId, formData.pointOfInterest)
    
    try {
      const qrCode = await generateQRCode({ text: url })
      
      const newPayLink = {
        amount: parseFloat(formData.amount),
        description: formData.description,
        merchantId,
        url,
        qrCode,
        ...(formData.pointOfInterest && { pointOfInterest: formData.pointOfInterest })
      }
      
      addPayLink(newPayLink)
      
      addActivity({
        type: 'payment',
        description: `Created pay link: ${formData.description} - $${formData.amount}`,
        status: 'completed'
      })
      
      setFormData({ amount: '', description: '', pointOfInterest: '' })
    } catch (error) {
      console.error('Failed to create pay link:', error)
    }
    
    setIsCreating(false)
  }

  const copyToClipboard = async (url: string, linkId: string) => {
    try {
      await navigator.clipboard.writeText(url)
      setCopiedLinkId(linkId)
      setTimeout(() => setCopiedLinkId(null), 2000)
    } catch (error) {
      console.error('Failed to copy:', error)
    }
  }

  const shareLink = async (url: string, description: string, amount: number) => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `Pay for ${description}`,
          text: `Pay $${amount} for ${description} on Unykorn`,
          url
        })
      } catch (error) {
        console.error('Failed to share:', error)
      }
    } else {
      copyToClipboard(url, 'share')
    }
  }

  const deletePayLink = (linkId: string) => {
    setPayLinks(prev => prev.filter(link => link.id !== linkId))
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
            className="text-center mb-12"
          >
            <div className="w-16 h-16 mx-auto mb-6 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center">
              <CreditCard className="w-8 h-8 text-white" />
            </div>
            
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              Merchant Portal
            </h1>
            
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Create payment links and QR codes to accept payments for your products and services
            </p>
          </motion.div>

          <div className="grid lg:grid-cols-3 gap-8">
            {/* Create New Pay Link */}
            <motion.div
              variants={fadeInUp}
              initial="initial"
              animate="animate"
              className="lg:col-span-1"
            >
              <Card className="glass-strong h-fit">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <Plus className="w-5 h-5" />
                    <span>Create Pay Link</span>
                  </CardTitle>
                  <CardDescription>
                    Generate a payment link for your product or service
                  </CardDescription>
                </CardHeader>
                
                <CardContent className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Amount (USD) *
                    </label>
                    <div className="relative">
                      <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <input
                        type="number"
                        value={formData.amount}
                        onChange={(e) => setFormData(prev => ({ ...prev, amount: e.target.value }))}
                        placeholder="0.00"
                        min="0"
                        step="0.01"
                        className="w-full pl-10 pr-3 py-2 glass rounded-lg border border-glass-border focus:outline-none focus:ring-2 focus:ring-primary text-sm"
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Description *
                    </label>
                    <input
                      type="text"
                      value={formData.description}
                      onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                      placeholder="e.g., Coffee & Consultation"
                      className="w-full px-3 py-2 glass rounded-lg border border-glass-border focus:outline-none focus:ring-2 focus:ring-primary text-sm"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Point of Interest
                    </label>
                    <input
                      type="text"
                      value={formData.pointOfInterest}
                      onChange={(e) => setFormData(prev => ({ ...prev, pointOfInterest: e.target.value }))}
                      placeholder="e.g., downtown-cafe"
                      className="w-full px-3 py-2 glass rounded-lg border border-glass-border focus:outline-none focus:ring-2 focus:ring-primary text-sm"
                    />
                    <p className="text-xs text-muted-foreground mt-1">
                      Optional: helps track location-based payments
                    </p>
                  </div>
                  
                  <Button
                    onClick={createPayLink}
                    disabled={!formData.amount || !formData.description || isCreating}
                    variant="gradient"
                    className="w-full"
                  >
                    {isCreating ? (
                      <>
                        <div className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin mr-2" />
                        Creating...
                      </>
                    ) : (
                      <>
                        <Plus className="w-4 h-4 mr-2" />
                        Create Pay Link
                      </>
                    )}
                  </Button>
                </CardContent>
              </Card>
            </motion.div>

            {/* Existing Pay Links */}
            <motion.div
              variants={fadeInUp}
              initial="initial"
              animate="animate"
              transition={{ delay: 0.2 }}
              className="lg:col-span-2"
            >
              <div className="space-y-4">
                <h2 className="text-2xl font-semibold">Your Pay Links</h2>
                
                {payLinks.length === 0 ? (
                  <Card className="glass">
                    <CardContent className="p-12 text-center">
                      <CreditCard className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                      <h3 className="text-lg font-medium mb-2">No pay links yet</h3>
                      <p className="text-muted-foreground">
                        Create your first pay link to start accepting payments
                      </p>
                    </CardContent>
                  </Card>
                ) : (
                  <div className="space-y-4">
                    {payLinks.map((link, index) => (
                      <motion.div
                        key={link.id}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 * index }}
                      >
                        <Card className="glass hover:glass-strong transition-all">
                          <CardContent className="p-6">
                            <div className="flex items-start justify-between">
                              <div className="flex-1">
                                <div className="flex items-center space-x-3 mb-2">
                                  <h3 className="text-lg font-semibold">
                                    {link.description}
                                  </h3>
                                  <span className="px-3 py-1 bg-gradient-to-r from-green-400 to-green-600 text-white rounded-full text-sm font-medium">
                                    ${link.amount}
                                  </span>
                                </div>
                                
                                <div className="flex items-center space-x-4 text-xs text-muted-foreground mb-4">
                                  <span>Created {link.createdAt.toLocaleDateString()}</span>
                                  <span>•</span>
                                  <span>{link.uses || 0} payments</span>
                                  {link.expiresAt && (
                                    <>
                                      <span>•</span>
                                      <span>Expires {link.expiresAt.toLocaleDateString()}</span>
                                    </>
                                  )}
                                </div>
                                
                                <div className="p-3 glass rounded-lg">
                                  <div className="flex items-center justify-between">
                                    <code className="text-xs text-muted-foreground truncate flex-1 mr-2">
                                      {link.url}
                                    </code>
                                    <div className="flex items-center space-x-2">
                                      <Button
                                        size="sm"
                                        variant="ghost"
                                        onClick={() => copyToClipboard(link.url, link.id)}
                                        className="flex items-center space-x-1"
                                      >
                                        <Copy className="w-3 h-3" />
                                        <span className="text-xs">
                                          {copiedLinkId === link.id ? 'Copied!' : 'Copy'}
                                        </span>
                                      </Button>
                                      
                                      <Button
                                        size="sm"
                                        variant="ghost"
                                        onClick={() => shareLink(link.url, link.description, link.amount)}
                                        className="flex items-center space-x-1"
                                      >
                                        <Share2 className="w-3 h-3" />
                                        <span className="text-xs">Share</span>
                                      </Button>
                                      
                                      <Button
                                        size="sm"
                                        variant="ghost"
                                        onClick={() => window.open(link.url, '_blank')}
                                        className="flex items-center space-x-1"
                                      >
                                        <ExternalLink className="w-3 h-3" />
                                        <span className="text-xs">Open</span>
                                      </Button>
                                      
                                      <Button
                                        size="sm"
                                        variant="ghost"
                                        onClick={() => deletePayLink(link.id)}
                                        className="flex items-center space-x-1 text-red-400 hover:text-red-300"
                                      >
                                        <Trash2 className="w-3 h-3" />
                                        <span className="text-xs">Delete</span>
                                      </Button>
                                    </div>
                                  </div>
                                </div>
                              </div>
                              
                              {link.qrCode && (
                                <div className="ml-6">
                                  <div className="w-24 h-24 p-2 glass rounded-lg">
                                    {/* eslint-disable-next-line @next/next/no-img-element */}
                                    <img
                                      src={link.qrCode}
                                      alt={`QR code for ${link.description}`}
                                      className="w-full h-full"
                                    />
                                  </div>
                                  <p className="text-xs text-center text-muted-foreground mt-1">
                                    QR Code
                                  </p>
                                </div>
                              )}
                            </div>
                          </CardContent>
                        </Card>
                      </motion.div>
                    ))}
                  </div>
                )}
              </div>
            </motion.div>
          </div>

          {/* Payment Features */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="mt-16"
          >
            <Card className="glass">
              <CardHeader className="text-center">
                <CardTitle className="text-2xl">Payment Features</CardTitle>
                <CardDescription>
                  Everything you need to accept payments smoothly
                </CardDescription>
              </CardHeader>
              
              <CardContent>
                <div className="grid md:grid-cols-3 gap-6">
                  <div className="text-center">
                    <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                      <QrCode className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="font-semibold mb-2">QR Codes</h3>
                    <p className="text-sm text-muted-foreground">
                      Automatic QR code generation for in-person payments
                    </p>
                  </div>
                  
                  <div className="text-center">
                    <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-br from-accent to-secondary flex items-center justify-center">
                      <CreditCard className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="font-semibold mb-2">Multiple Chains</h3>
                    <p className="text-sm text-muted-foreground">
                      Accept payments on Ethereum, Polygon, Base, and more
                    </p>
                  </div>
                  
                  <div className="text-center">
                    <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-br from-secondary to-primary flex items-center justify-center">
                      <DollarSign className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="font-semibold mb-2">Real-time Tracking</h3>
                    <p className="text-sm text-muted-foreground">
                      Monitor payments and payouts in your dashboard
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </main>
    </>
  )
}