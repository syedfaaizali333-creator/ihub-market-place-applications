# iHub Marketplace — Responsive Web App

A web-first marketplace starter built with **Next.js App Router, TypeScript, Tailwind CSS, Supabase Auth, PostgreSQL, and Row Level Security**. Product imagery from the supplied `apple-store.zip` is bundled locally under `public/assets/`.

## Included in this project

- Responsive marketplace storefront with product search, category filters, saved-item toggles, demo cart interactions, service cards and motion-reduced support.
- Supabase email/password sign-up and sign-in, Google OAuth entry, email confirmation callback, and password reset.
- Middleware-protected `/dashboard` and `/admin` routes.
- User dashboard reading the authenticated user's profile from PostgreSQL.
- Admin dashboard protected by a database `profiles.role = 'admin'` check and showing live counts for profiles, products and vendors.
- PostgreSQL schema and RLS policies for profiles, vendors, products, wishlist and orders.
- `.env.example`, deployment notes and setup guide.

## Important scope notes

This is a working **web MVP foundation**, not a claim that every marketplace workflow is production complete. The current storefront's sample catalog and cart are front-end demo interactions. Order placement, live checkout/payment, vendor application screens, product upload/storage, repair bookings, exchange offers, chat, push notifications and full admin CRUD are not implemented yet. No real payment is taken. The schema intentionally has no direct client-side product/order write policy; trusted server-side actions should be added before enabling those workflows.

The supplied images are Apple-branded product imagery. Use only assets you have permission to publish in your deployed marketplace.

## Requirements

- Node.js 20.9+ (Node 22 recommended)
- npm
- A Supabase project
- Google OAuth credentials if Google sign-in is enabled

## 1. Install and run locally

1. Extract this project ZIP.
2. Open a terminal in the extracted `ihub-marketplace-web` folder.
3. Install dependencies:

   ```bash
   npm install
   ```

4. Copy `.env.example` to `.env.local`.
5. Add your Supabase project URL and publishable/anon key in `.env.local`:

   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY
   NEXT_PUBLIC_SITE_URL=http://localhost:3000
   ```

   Never put a Supabase `service_role` secret in a `NEXT_PUBLIC_` variable or frontend code.

6. In Supabase Dashboard → SQL Editor, run `supabase/schema.sql`.
7. In Supabase Dashboard → Authentication → URL Configuration, set the Site URL to `http://localhost:3000` and add this redirect URL:

   `http://localhost:3000/auth/callback`

8. Run:

   ```bash
   npm run dev
   ```

9. Open `http://localhost:3000`.

If Supabase environment variables are absent, the storefront still renders, but sign-in and database features cannot work. Set environment variables and restart the dev server after changing them.

## 2. Configure Google OAuth

1. Supabase Dashboard → Authentication → Providers → Google.
2. Enable Google and add the OAuth Client ID and Client Secret from Google Cloud Console.
3. Copy the Supabase callback URL displayed by Supabase into the Google OAuth client's authorized redirect URIs.
4. In Supabase URL Configuration, allow `http://localhost:3000/auth/callback` for local development and your actual production callback URL for deployment.
5. Test sign-in using a real Google account you control.

Provider settings can change; follow the current callback URL shown in your own Supabase project.

## 3. Create the first admin safely

1. Register a normal account through `/signup` and confirm the email if email confirmation is enabled.
2. In Supabase Dashboard → SQL Editor, run:

   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'REPLACE-WITH-THE-AUTH-USER-UUID';
   ```

3. Find the UUID in Authentication → Users. Confirm the target account before running the update.
4. Sign out and sign in again, then visit `/admin`.

Do not add an admin selector or role field to the public signup form. Only a trusted project owner should grant admin access. RLS policies and server-side checks remain necessary; hiding a URL is not security.

## 4. Database and security notes

- `profiles.role` defaults to `user`; public signup cannot select the role.
- `is_admin()` checks the current authenticated user's profile in PostgreSQL.
- Public visitors can read approved product/vendor listings; owners can read their own pending records.
- Orders have read policies but no client-side insert/update policy. Implement checkout through a trusted server action or Supabase Edge Function that validates prices and stock on the server.
- Do not trust prices, discounts, totals, stock, vendor approval or trusted badges sent from the browser.
- Review RLS policies with the Supabase SQL editor and test as anonymous, ordinary user, vendor and admin before launch.
- For vendor verification files, create a private Storage bucket and strict object policies; do not expose identity documents in public storage.
- Set up rate limits, CAPTCHA/abuse controls where appropriate, backups, monitoring and privacy/legal pages before public production use.

## 5. Production deployment (e.g. Vercel)

1. Push the extracted project to your Git repository.
2. Import the repository into Vercel; the framework should be detected as Next.js.
3. Add `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` and `NEXT_PUBLIC_SITE_URL` in the Vercel project environment settings for Preview and Production as appropriate.
4. Add the production URL and `/auth/callback` to Supabase Authentication URL Configuration. Also add preview URLs only if you intend to test OAuth on previews.
5. Deploy and test signup, email confirmation, login, Google OAuth, logout, user-only routes, and admin denial from a normal account.
6. Add your custom domain in Vercel and verify DNS/TLS; update Supabase Site URL and redirect allowlist to match the canonical domain.

## 6. Useful commands

```bash
npm run dev      # local development
npm run build    # production build
npm run start    # serve production build
```

## File structure

```text
app/
  auth/callback/route.ts
  admin/page.tsx
  dashboard/page.tsx
  login/page.tsx
  signup/page.tsx
  globals.css
  layout.tsx
  page.tsx
components/
  account-panel.tsx
  admin-signout.tsx
  auth-form.tsx
  navbar.tsx
  storefront.tsx
lib/
  supabase.ts
  supabase-server.ts
public/assets/       # supplied product images
supabase/schema.sql  # schema + RLS policies
middleware.ts
.env.example
```
