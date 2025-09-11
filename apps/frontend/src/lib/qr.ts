import QRCode from 'qrcode'

export interface GenerateQROptions {
  text: string
  size?: number
  darkColor?: string
  lightColor?: string
}

export async function generateQRCode({
  text,
  size = 256,
  darkColor = '#000000',
  lightColor = '#FFFFFF'
}: GenerateQROptions): Promise<string> {
  try {
    const qrCodeDataUrl = await QRCode.toDataURL(text, {
      width: size,
      margin: 2,
      color: {
        dark: darkColor,
        light: lightColor,
      },
      errorCorrectionLevel: 'M',
    })
    return qrCodeDataUrl
  } catch (error) {
    console.error('Error generating QR code:', error)
    throw new Error('Failed to generate QR code')
  }
}

export function generateShareUrl(type: 'join' | 'pay', params: Record<string, string>): string {
  const baseUrl = typeof window !== 'undefined' ? window.location.origin : 'https://unykorn.com'
  const searchParams = new URLSearchParams(params)
  return `${baseUrl}/${type}?${searchParams.toString()}`
}

export function generateJoinUrl(beaconId: string): string {
  return generateShareUrl('join', { b: beaconId })
}

export function generatePayUrl(amount: string, merchant: string, pointOfInterest?: string): string {
  const params: Record<string, string> = { amt: amount, m: merchant }
  if (pointOfInterest) {
    params.poi = pointOfInterest
  }
  return generateShareUrl('pay', params)
}