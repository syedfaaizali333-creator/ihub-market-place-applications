import { Suspense } from 'react';
import { AuthForm } from '@/components/auth-form';
export default function SignupPage() { return <main><Suspense fallback={<div className="loading-screen">Loading account form…</div>}><AuthForm mode="signup"/></Suspense></main>; }
