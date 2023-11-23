import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import Header from "../app/components/Header";
import ThemeRegistry from './ThemeRegistry';
import Sidebar from "./components/Sidebar"

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'KX.AS.Code Portal',
  description: 'KX.AS.Code Portal',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Header />
        <ThemeRegistry options={{ key: 'mui' }}>
        <Sidebar sidebarOpen={true} />
          {children}
        </ThemeRegistry>
      </body>
    </html>
  )
}
