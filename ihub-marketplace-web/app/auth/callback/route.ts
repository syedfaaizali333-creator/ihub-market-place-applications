import { NextResponse } from 'next/server';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import type { NextRequest } from 'next/server';
export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url); const code = searchParams.get('code'); const next = searchParams.get('next') ?? '/dashboard';
  if (code && process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
    const cookieStore = await cookies(); const supabase = createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY, { cookies: { getAll: () => cookieStore.getAll(), setAll: list => list.forEach(({name,value,options}) => cookieStore.set(name,value,options)) } });
    const { error } = await supabase.auth.exchangeCodeForSession(code); if (!error) return NextResponse.redirect(new URL(next.startsWith('/') ? next : '/dashboard', origin));
  }
  return NextResponse.redirect(new URL('/login?error=oauth_callback_failed', origin));
}
