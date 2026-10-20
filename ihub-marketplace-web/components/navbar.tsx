'use client';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { Menu, ShoppingBag, X } from 'lucide-react';
import { createClient } from '@/lib/supabase';

export function Navbar() {
  const [open, setOpen] = useState(false);
  const [signedIn, setSignedIn] = useState(false);
  useEffect(() => {
    try {
      const supabase = createClient();
      supabase.auth.getSession().then(({ data }) => setSignedIn(Boolean(data.session)));
      const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => setSignedIn(Boolean(session)));
      return () => listener.subscription.unsubscribe();
    } catch { /* Keep public navigation usable until Supabase is configured. */ }
  }, []);
  const links = <><Link href="/#shop" onClick={() => setOpen(false)}>Shop</Link><Link href="/#services" onClick={() => setOpen(false)}>Services</Link><Link href="/#about" onClick={() => setOpen(false)}>About</Link><Link href="/dashboard" onClick={() => setOpen(false)}>My account</Link></>;
  return <header className="navbar"><div className="container nav-inner"><Link href="/" className="brand">i<span>Hub</span><small> MARKETPLACE</small></Link><nav className={open ? 'nav-links open' : 'nav-links'}>{links}<Link href="/login" className="mobile-login" onClick={() => setOpen(false)}>{signedIn ? 'Account' : 'Sign in'}</Link></nav><div className="nav-actions"><Link href="/#shop" className="icon-link" aria-label="Browse products"><ShoppingBag size={19}/></Link><Link className="button button-dark nav-login" href={signedIn ? '/dashboard' : '/login'}>{signedIn ? 'My account' : 'Sign in'}</Link><button className="menu-button" onClick={() => setOpen(!open)} aria-label="Toggle menu">{open ? <X/> : <Menu/>}</button></div></div></header>;
}
