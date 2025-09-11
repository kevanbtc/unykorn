import type { Metadata } from "next";
import "./globals.css";
import '@rainbow-me/rainbowkit/styles.css';
import { Web3Provider } from '@/components/providers/web3-provider';
import { Navigation } from '@/components/navigation';

export const metadata: Metadata = {
  title: "Unykorn - Turn Time & Intros Into Value",
  description: "Scan. Share. Get paid when real commerce happens. The future of Web3 onboarding and rewards.",
  keywords: ["Web3", "blockchain", "rewards", "onboarding", "cryptocurrency"],
  authors: [{ name: "Unykorn Team" }],
  openGraph: {
    title: "Unykorn - Turn Time & Intros Into Value",
    description: "Scan. Share. Get paid when real commerce happens.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="font-sans antialiased">
        <Web3Provider>
          <Navigation />
          <main className="pt-16">
            {children}
          </main>
        </Web3Provider>
      </body>
    </html>
  );
}
