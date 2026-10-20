'use client';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase';
export function AdminSignOut() { const router = useRouter(); return <button className="admin-signout" onClick={async()=>{const supabase=createClient(); await supabase.auth.signOut(); router.push('/login'); router.refresh();}}>Sign out</button>; }
