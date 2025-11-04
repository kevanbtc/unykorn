import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',
  compress: true,
  poweredByHeader: false,
  
  experimental: {
    optimizePackageImports: ['framer-motion', 'lucide-react']
  },

  images: {
    formats: ['image/webp', 'image/avif'],
    minimumCacheTTL: 60,
    dangerouslyAllowSVG: true,
    contentDispositionType: 'attachment',
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
  },

  eslint: {
    dirs: ['src']
  },

  env: {
    NEXT_PUBLIC_ENV: process.env.NODE_ENV || 'development'
  }
};

export default nextConfig;
