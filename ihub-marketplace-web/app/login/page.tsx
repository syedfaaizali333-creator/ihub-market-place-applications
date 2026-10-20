import { Suspense } from 'react';
import { AuthForm } from '@/components/auth-form';
export default function LoginPage() { return <main><Suspense fallback={<div className="loading-screen">Loading sign in…</div>}><AuthForm mode="login"/></Suspense></main>; }
