import QRCode from 'qrcode'

export interface QRCodeOptions {
  width?: number
  margin?: number
  color?: {
    dark?: string
    light?: string
  }
}

export async function generateQRCode(
  text: string, 
  options: QRCodeOptions = {}
): Promise<string> {
  const defaultOptions = {
    width: 256,
    margin: 2,
    color: {
      dark: '#000000',
      light: '#FFFFFF'
    },
    ...options
  }

  try {
    return await QRCode.toDataURL(text, defaultOptions)
  } catch (error) {
    console.error('Error generating QR code:', error)
    throw new Error('Failed to generate QR code')
  }
}

export function createJoinLink(beaconId: string): string {
  return `${typeof window !== 'undefined' ? window.location.origin : ''}/join?b=${beaconId}`
}

export function createPayLink(amount: string, merchant: string, pointOfInterest?: string): string {
  const params = new URLSearchParams({
    amt: amount,
    m: merchant,
    ...(pointOfInterest && { poi: pointOfInterest })
  })
  
  return `${typeof window !== 'undefined' ? window.location.origin : ''}/pay?${params.toString()}`
}