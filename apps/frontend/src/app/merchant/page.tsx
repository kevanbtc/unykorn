'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { DollarSign, QrCode, Store, Copy, Check, ExternalLink } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { generateQRCode, createPayLink } from '@/lib/qr'
import { useAppStore } from '@/stores/app-store'

const payLinkSchema = z.object({
  amount: z.string().min(1, 'Amount is required').regex(/^\d+(\.\d{1,2})?$/, 'Invalid amount format'),
  merchant: z.string().min(2, 'Merchant name must be at least 2 characters'),
  description: z.string().min(5, 'Description must be at least 5 characters'),
  pointOfInterest: z.string().optional()
})

type PayLinkForm = z.infer<typeof payLinkSchema>

export default function MerchantPage() {
  const [qrCodeUrl, setQrCodeUrl] = useState<string>('')
  const [paymentLink, setPaymentLink] = useState<string>('')
  const [copied, setCopied] = useState(false)
  const [isGenerating, setIsGenerating] = useState(false)
  
  const { addPayLink, addNotification } = useAppStore()

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset
  } = useForm<PayLinkForm>({
    resolver: zodResolver(payLinkSchema)
  })

  const onSubmit = async (data: PayLinkForm) => {
    setIsGenerating(true)

    try {
      // Create payment link
      const link = createPayLink(data.amount, data.merchant, data.pointOfInterest)
      
      // Generate QR code
      const qrCode = await generateQRCode(link, {
        width: 200,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      })

      setPaymentLink(link)
      setQrCodeUrl(qrCode)

      // Add to store
      addPayLink({
        amount: parseFloat(data.amount),
        merchant: data.merchant,
        description: data.description,
        qrCode,
        shortUrl: link,
        pointOfInterest: data.pointOfInterest,
        isActive: true
      })

      addNotification({
        type: 'success',
        title: 'Payment link created!',
        message: 'Your payment link and QR code are ready to share.'
      })

    } catch (error) {
      console.error('Error creating payment link:', error)
      addNotification({
        type: 'error',
        title: 'Error',
        message: 'Failed to create payment link. Please try again.'
      })
    } finally {
      setIsGenerating(false)
    }
  }

  const copyToClipboard = async () => {
    if (!paymentLink) return
    
    try {
      await navigator.clipboard.writeText(paymentLink)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
      
      addNotification({
        type: 'success',
        title: 'Copied!',
        message: 'Payment link copied to clipboard.'
      })
    } catch (error) {
      console.error('Failed to copy:', error)
    }
  }

  const createNewLink = () => {
    reset()
    setPaymentLink('')
    setQrCodeUrl('')
    setCopied(false)
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
            Create payment{' '}
            <span className="bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
              links
            </span>
          </h1>
          <p className="text-xl text-white/80 max-w-2xl mx-auto">
            Generate instant payment links and QR codes for your business. Accept payments seamlessly with Web3.
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-2 gap-8">
          {/* Payment Link Form */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Store className="h-6 w-6 text-indigo-400" />
                  Payment Details
                </CardTitle>
                <CardDescription>
                  Create a payment link for your products or services
                </CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Amount (USD)
                    </label>
                    <Input
                      {...register('amount')}
                      placeholder="29.99"
                      error={errors.amount?.message}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Merchant Name
                    </label>
                    <Input
                      {...register('merchant')}
                      placeholder="Your Business Name"
                      error={errors.merchant?.message}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Description
                    </label>
                    <Input
                      {...register('description')}
                      placeholder="Premium subscription, Coffee, etc."
                      error={errors.description?.message}
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Point of Interest (Optional)
                    </label>
                    <Input
                      {...register('pointOfInterest')}
                      placeholder="Location, event, or special note"
                    />
                  </div>

                  <Button
                    type="submit"
                    disabled={isGenerating}
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
                        Creating...
                      </>
                    ) : (
                      <>
                        <QrCode className="mr-2 h-5 w-5" />
                        Create Payment Link
                      </>
                    )}
                  </Button>
                </form>
              </CardContent>
            </Card>
          </motion.div>

          {/* Generated Payment Link */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <DollarSign className="h-6 w-6 text-green-400" />
                  Payment Link
                </CardTitle>
                <CardDescription>
                  {paymentLink ? 'Your payment link is ready!' : 'Your payment link will appear here'}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {paymentLink ? (
                  <div className="space-y-6">
                    {/* QR Code */}
                    {qrCodeUrl && (
                      <div className="text-center">
                        <div className="inline-block p-4 bg-white rounded-lg">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img 
                            src={qrCodeUrl} 
                            alt="Payment QR Code" 
                            className="w-48 h-48 mx-auto"
                          />
                        </div>
                        <p className="text-sm text-white/60 mt-2">
                          Scan to pay instantly
                        </p>
                      </div>
                    )}

                    {/* Link Actions */}
                    <div className="space-y-3">
                      <div className="flex gap-2">
                        <Input
                          value={paymentLink}
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
                        <Button
                          asChild
                          variant="secondary"
                          size="sm"
                          className="w-full"
                        >
                          <a 
                            href={paymentLink} 
                            target="_blank" 
                            rel="noopener noreferrer"
                          >
                            <ExternalLink className="mr-2 h-4 w-4" />
                            Preview
                          </a>
                        </Button>
                        <Button
                          onClick={createNewLink}
                          variant="outline"
                          size="sm"
                          className="w-full"
                        >
                          Create New
                        </Button>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-12 text-white/50">
                    <DollarSign className="h-16 w-16 mx-auto mb-4 opacity-50" />
                    <p>Fill out the form to generate your payment link and QR code</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        </div>

        {/* Features Section */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="mt-12"
        >
          <Card>
            <CardHeader>
              <CardTitle>🚀 Payment Link Features</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid md:grid-cols-3 gap-6">
                <div className="text-center">
                  <div className="w-12 h-12 mx-auto mb-3 rounded-lg bg-gradient-to-r from-blue-500 to-cyan-500 flex items-center justify-center">
                    <QrCode className="h-6 w-6 text-white" />
                  </div>
                  <h4 className="font-semibold text-white mb-2">QR Code Ready</h4>
                  <p className="text-sm text-white/70">
                    Instant QR codes for mobile payments and offline transactions.
                  </p>
                </div>
                
                <div className="text-center">
                  <div className="w-12 h-12 mx-auto mb-3 rounded-lg bg-gradient-to-r from-green-500 to-emerald-500 flex items-center justify-center">
                    <DollarSign className="h-6 w-6 text-white" />
                  </div>
                  <h4 className="font-semibold text-white mb-2">Multi-Chain</h4>
                  <p className="text-sm text-white/70">
                    Accept payments on Ethereum, Polygon, Arbitrum, and more.
                  </p>
                </div>
                
                <div className="text-center">
                  <div className="w-12 h-12 mx-auto mb-3 rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center">
                    <Store className="h-6 w-6 text-white" />
                  </div>
                  <h4 className="font-semibold text-white mb-2">Business Ready</h4>
                  <p className="text-sm text-white/70">
                    Professional payment links perfect for e-commerce and services.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  )
}