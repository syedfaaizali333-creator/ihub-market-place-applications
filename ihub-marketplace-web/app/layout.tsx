import type { Metadata } from 'next';
import './globals.css';
import { Navbar } from '@/components/navbar';

export const metadata: Metadata = {
  title: 'iHub Marketplace — Buy. Repair. Customize. Exchange.',
  description: 'Your iPhone. Your Choice. Your Marketplace. Shop iPhones, accessories, repairs and custom covers.',
};
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body><Navbar />{children}<footer className="footer"><div className="container footer-inner"><a className="brand" href="/">i<span>Hub</span></a><p>Your iPhone. Your Choice. Your Marketplace.</p><span>© {new Date().getFullYear()} iHub Marketplace</span></div></footer></body></html>;
}
