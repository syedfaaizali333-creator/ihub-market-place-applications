'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase';
import { LogOut } from 'lucide-react';
export function AccountPanel({ email }: { email: string }) { const [busy,setBusy] = useState(false); const router = useRouter(); async function signOut() { setBusy(true); try { const supabase = createClient(); await supabase.auth.signOut(); router.push('/'); router.refresh(); } finally { setBusy(false); } } return <div className="signed-in-pill"><span className="avatar-dot">{email.slice(0,1).toUpperCase()}</span><span className="signed-email">{email}</span><button onClick={signOut} disabled={busy} title="Sign out" aria-label="Sign out"><LogOut size={17}/></button></div>; }
