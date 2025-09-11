import type { Metadata } from "next";
import "./globals.css";
import { Web3Provider } from "@/components/providers/web3-provider";

export const metadata: Metadata = {
  title: "Unykorn - Turn time & intros into value",
  description: "Scan. Share. Get paid when real commerce happens. Web3 onboarding made simple.",
  keywords: ["Web3", "DeFi", "NFT", "Cryptocurrency", "Onboarding"],
  authors: [{ name: "Unykorn Team" }],
  openGraph: {
    title: "Unykorn - Turn time & intros into value",
    description: "Scan. Share. Get paid when real commerce happens.",
    type: "website",
    url: "https://unykorn.com",
  },
  twitter: {
    card: "summary_large_image",
    title: "Unykorn - Turn time & intros into value",
    description: "Scan. Share. Get paid when real commerce happens.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="font-sans antialiased">
        <Web3Provider>
          {children}
        </Web3Provider>
      </body>
    </html>
  );
}
