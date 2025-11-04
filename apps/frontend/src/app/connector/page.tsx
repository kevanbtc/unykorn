'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Copy, QrCode, Share2, Users, ExternalLink, Check } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { generateQRCode, createJoinLink } from '@/lib/qr'
import { useAppStore } from '@/stores/app-store'

export default function ConnectorPage() {
  const [introText, setIntroText] = useState('')
  const [qrCodeUrl, setQrCodeUrl] = useState<string>('')
  const [shareLink, setShareLink] = useState<string>('')
  const [copied, setCopied] = useState(false)
  const [isGenerating, setIsGenerating] = useState(false)
  
  const { addActivity, addNotification } = useAppStore()

  const generateIntroLink = async () => {
    if (!introText.trim()) return

    setIsGenerating(true)
    
    try {
      // Generate a unique beacon ID
      const beaconId = crypto.randomUUID().slice(0, 8)
      const joinLink = createJoinLink(beaconId)
      
      // Generate QR code
      const qrCode = await generateQRCode(joinLink, {
        width: 200,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      })

      setShareLink(joinLink)
      setQrCodeUrl(qrCode)

      // Add activity
      addActivity({
        type: 'connect',
        description: `Created intro link: "${introText}"`,
        status: 'completed'
      })

      addNotification({
        type: 'success',
        title: 'Intro link created!',
        message: 'Your shareable link and QR code are ready.'
      })

    } catch (error) {
      console.error('Error generating intro link:', error)
      addNotification({
        type: 'error',
        title: 'Error',
        message: 'Failed to generate intro link. Please try again.'
      })
    } finally {
      setIsGenerating(false)
    }
  }

  const copyToClipboard = async () => {
    if (!shareLink) return
    
    try {
      await navigator.clipboard.writeText(shareLink)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
      
      addNotification({
        type: 'success',
        title: 'Copied!',
        message: 'Link copied to clipboard.'
      })
    } catch (error) {
      console.error('Failed to copy:', error)
    }
  }

  const shareViaWeb = async () => {
    if (!shareLink || typeof window === 'undefined' || !('share' in navigator)) return

    try {
      await navigator.share({
        title: 'Join Unykorn',
        text: introText || 'Join me on Unykorn!',
        url: shareLink
      })
    } catch (error) {
      console.error('Error sharing:', error)
    }
  }

  return (
    <div className="min-h-screen py-12 px-4">
      <div className="max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <h1 className="text-4xl md:text-6xl font-bold text-white mb-6">
            Share meaningful{' '}
            <span className="bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
              connections
            </span>
          </h1>
          <p className="text-xl text-white/80 max-w-2xl mx-auto">
            Create intro links that turn conversations into opportunities. Earn when connections lead to commerce.
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-2 gap-8">
          {/* Create Link Form */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Users className="h-6 w-6 text-indigo-400" />
                  Create Intro Link
                </CardTitle>
                <CardDescription>
                  Share a personalized invitation to join Unykorn
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-white/80 mb-2">
                    Introduction Message
                  </label>
                  <Input
                    placeholder="e.g., Join me on this amazing Web3 platform..."
                    value={introText}
                    onChange={(e) => setIntroText(e.target.value)}
                    className="w-full"
                  />
                  <p className="text-xs text-white/50 mt-1">
                    This message will be included when you share the link
                  </p>
                </div>

                <Button
                  onClick={generateIntroLink}
                  disabled={!introText.trim() || isGenerating}
                  variant="primary"
                  size="lg"
                  className="w-full"
                >
                  {isGenerating ? (
                    <>
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                        className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full mr-2"
                      />
                      Generating...
                    </>
                  ) : (
                    <>
                      <QrCode className="mr-2 h-5 w-5" />
                      Generate Link & QR Code
                    </>
                  )}
                </Button>
              </CardContent>
            </Card>
          </motion.div>

          {/* Generated Link & QR Code */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Share2 className="h-6 w-6 text-green-400" />
                  Share Your Link
                </CardTitle>
                <CardDescription>
                  {shareLink ? 'Your intro link is ready to share!' : 'Your shareable content will appear here'}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {shareLink ? (
                  <div className="space-y-6">
                    {/* QR Code */}
                    {qrCodeUrl && (
                      <div className="text-center">
                        <div className="inline-block p-4 bg-white rounded-lg">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img 
                            src={qrCodeUrl} 
                            alt="QR Code" 
                            className="w-48 h-48 mx-auto"
                          />
                        </div>
                        <p className="text-sm text-white/60 mt-2">
                          Scan to join via mobile
                        </p>
                      </div>
                    )}

                    {/* Link Actions */}
                    <div className="space-y-3">
                      <div className="flex gap-2">
                        <Input
                          value={shareLink}
                          readOnly
                          className="flex-1 text-sm"
                        />
                        <Button
                          onClick={copyToClipboard}
                          variant="outline"
                          size="default"
                          className="px-3"
                        >
                          {copied ? (
                            <Check className="h-4 w-4 text-green-400" />
                          ) : (
                            <Copy className="h-4 w-4" />
                          )}
                        </Button>
                      </div>

                      <div className="grid grid-cols-2 gap-2">
                        {typeof window !== 'undefined' && 'share' in navigator && (
                          <Button
                            onClick={shareViaWeb}
                            variant="secondary"
                            size="sm"
                            className="w-full"
                          >
                            <Share2 className="mr-2 h-4 w-4" />
                            Share
                          </Button>
                        )}
                        <Button
                          asChild
                          variant="outline"
                          size="sm"
                          className="w-full"
                        >
                          <a 
                            href={shareLink} 
                            target="_blank" 
                            rel="noopener noreferrer"
                          >
                            <ExternalLink className="mr-2 h-4 w-4" />
                            Preview
                          </a>
                        </Button>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-12 text-white/50">
                    <QrCode className="h-16 w-16 mx-auto mb-4 opacity-50" />
                    <p>Create an intro link to see your QR code and sharing options</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Tips Section */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="mt-12"
        >
          <Card>
            <CardHeader>
              <CardTitle>💡 Tips for Effective Connections</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid md:grid-cols-3 gap-4 text-sm text-white/80">
                <div>
                  <h4 className="font-semibold mb-2">Personal Touch</h4>
                  <p>Add a personal message explaining why you think they&apos;d be interested in Unykorn.</p>
                </div>
                <div>
                  <h4 className="font-semibold mb-2">Right Timing</h4>
                  <p>Share when people are most likely to engage - during conversations about opportunities.</p>
                </div>
                <div>
                  <h4 className="font-semibold mb-2">Follow Up</h4>
                  <p>Check in with people you&apos;ve invited and help them get started on the platform.</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  )
}