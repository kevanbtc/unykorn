'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Copy, Share2, Users, QrCode, ExternalLink, Plus } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import Navigation from '@/components/navigation'
import { generateJoinUrl, generateQRCode } from '@/lib/qr'
import { useAppStore } from '@/lib/store'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.3, ease: 'easeOut' }
}

interface IntroLink {
  id: string
  title: string
  description: string
  url: string
  qrCode?: string
  created: Date
  uses: number
}

export default function ConnectorPage() {
  const [introLinks, setIntroLinks] = useState<IntroLink[]>([])
  const [isCreating, setIsCreating] = useState(false)
  const [newLinkTitle, setNewLinkTitle] = useState('')
  const [newLinkDescription, setNewLinkDescription] = useState('')
  const [copiedLinkId, setCopiedLinkId] = useState<string | null>(null)
  const { addActivity } = useAppStore()

  // Mock existing intro links
  useEffect(() => {
    setIntroLinks([
      {
        id: 'intro-001',
        title: 'Coffee & Crypto Meetup',
        description: 'Local entrepreneurs interested in Web3',
        url: generateJoinUrl('beacon-coffee-123'),
        created: new Date('2024-01-15'),
        uses: 12
      },
      {
        id: 'intro-002',
        title: 'Startup Founders Circle',
        description: 'Monthly networking for tech founders',
        url: generateJoinUrl('beacon-founders-456'),
        created: new Date('2024-01-10'),
        uses: 8
      }
    ])
  }, [])

  const createIntroLink = async () => {
    if (!newLinkTitle.trim()) return
    
    setIsCreating(true)
    
    const beaconId = `beacon-${Date.now()}`
    const url = generateJoinUrl(beaconId)
    
    try {
      const qrCode = await generateQRCode({ text: url })
      
      const newLink: IntroLink = {
        id: `intro-${Date.now()}`,
        title: newLinkTitle,
        description: newLinkDescription,
        url,
        qrCode,
        created: new Date(),
        uses: 0
      }
      
      setIntroLinks(prev => [newLink, ...prev])
      
      addActivity({
        type: 'intro',
        description: `Created intro link: ${newLinkTitle}`,
        status: 'completed'
      })
      
      setNewLinkTitle('')
      setNewLinkDescription('')
    } catch (error) {
      console.error('Failed to create intro link:', error)
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

  const shareLink = async (url: string, title: string) => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `Join ${title} on Unykorn`,
          text: 'Join this exclusive community on Unykorn',
          url
        })
      } catch (error) {
        console.error('Failed to share:', error)
      }
    } else {
      // Fallback to copy
      copyToClipboard(url, 'share')
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
            className="text-center mb-12"
          >
            <div className="w-16 h-16 mx-auto mb-6 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center">
              <Users className="w-8 h-8 text-white" />
            </div>
            
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              Share Connections
            </h1>
            
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Create shareable intro links and QR codes to onboard your network into Web3
            </p>
          </motion.div>

          <div className="grid lg:grid-cols-3 gap-8">
            {/* Create New Intro Link */}
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
                    <span>Create Intro Link</span>
                  </CardTitle>
                  <CardDescription>
                    Generate a new link for your community or event
                  </CardDescription>
                </CardHeader>
                
                <CardContent className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Title *
                    </label>
                    <input
                      type="text"
                      value={newLinkTitle}
                      onChange={(e) => setNewLinkTitle(e.target.value)}
                      placeholder="e.g., Tech Meetup NYC"
                      className="w-full px-3 py-2 glass rounded-lg border border-glass-border focus:outline-none focus:ring-2 focus:ring-primary text-sm"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Description
                    </label>
                    <textarea
                      value={newLinkDescription}
                      onChange={(e) => setNewLinkDescription(e.target.value)}
                      placeholder="Brief description of the group or event"
                      rows={3}
                      className="w-full px-3 py-2 glass rounded-lg border border-glass-border focus:outline-none focus:ring-2 focus:ring-primary text-sm resize-none"
                    />
                  </div>
                  
                  <Button
                    onClick={createIntroLink}
                    disabled={!newLinkTitle.trim() || isCreating}
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
                        Create Link
                      </>
                    )}
                  </Button>
                </CardContent>
              </Card>
            </motion.div>

            {/* Existing Intro Links */}
            <motion.div
              variants={fadeInUp}
              initial="initial"
              animate="animate"
              transition={{ delay: 0.2 }}
              className="lg:col-span-2"
            >
              <div className="space-y-4">
                <h2 className="text-2xl font-semibold">Your Intro Links</h2>
                
                {introLinks.length === 0 ? (
                  <Card className="glass">
                    <CardContent className="p-12 text-center">
                      <Users className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                      <h3 className="text-lg font-medium mb-2">No intro links yet</h3>
                      <p className="text-muted-foreground">
                        Create your first intro link to start connecting people
                      </p>
                    </CardContent>
                  </Card>
                ) : (
                  <div className="space-y-4">
                    {introLinks.map((link, index) => (
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
                                <h3 className="text-lg font-semibold mb-1">
                                  {link.title}
                                </h3>
                                <p className="text-muted-foreground text-sm mb-3">
                                  {link.description}
                                </p>
                                
                                <div className="flex items-center space-x-4 text-xs text-muted-foreground">
                                  <span>Created {link.created.toLocaleDateString()}</span>
                                  <span>•</span>
                                  <span>{link.uses} uses</span>
                                </div>
                                
                                <div className="mt-4 p-3 glass rounded-lg">
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
                                        onClick={() => shareLink(link.url, link.title)}
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
                                      alt={`QR code for ${link.title}`}
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

          {/* How it Works */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="mt-16"
          >
            <Card className="glass">
              <CardHeader className="text-center">
                <CardTitle className="text-2xl">How It Works</CardTitle>
                <CardDescription>
                  Simple steps to connect your network to Web3
                </CardDescription>
              </CardHeader>
              
              <CardContent>
                <div className="grid md:grid-cols-3 gap-6">
                  <div className="text-center">
                    <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                      <Plus className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="font-semibold mb-2">1. Create</h3>
                    <p className="text-sm text-muted-foreground">
                      Generate a custom intro link for your community or event
                    </p>
                  </div>
                  
                  <div className="text-center">
                    <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-br from-accent to-secondary flex items-center justify-center">
                      <QrCode className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="font-semibold mb-2">2. Share</h3>
                    <p className="text-sm text-muted-foreground">
                      Share the link or QR code via social media, email, or print
                    </p>
                  </div>
                  
                  <div className="text-center">
                    <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-br from-secondary to-primary flex items-center justify-center">
                      <Users className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="font-semibold mb-2">3. Connect</h3>
                    <p className="text-sm text-muted-foreground">
                      People join with one tap and you earn when they transact
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