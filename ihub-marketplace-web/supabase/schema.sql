-- iHub Marketplace / Supabase PostgreSQL schema
-- Run in Supabase Dashboard -> SQL Editor. Review before production use.
create extension if not exists pgcrypto;

do $$ begin
  create type public.account_role as enum ('user','vendor','admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.vendor_status as enum ('pending_review','approved','rejected','suspended');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.product_status as enum ('pending_review','approved','rejected','suspended');
exception when duplicate_object then null; end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text,
  role public.account_role not null default 'user',
  status text not null default 'active' check (status in ('active','restricted','suspended')),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.vendors (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references public.profiles(id) on delete cascade,
  shop_name text not null,
  description text not null default '',
  city text not null default '',
  contact_phone text not null default '',
  status public.vendor_status not null default 'pending_review',
  trusted boolean not null default false,
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid references public.vendors(id) on delete set null,
  name text not null check (char_length(name) between 3 and 120),
  category text not null,
  description text not null default '',
  price numeric(12,2) not null check (price > 0),
  image_url text,
  stock integer not null default 0 check (stock >= 0),
  status public.product_status not null default 'pending_review',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.wishlist (
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id) on delete restrict,
  status text not null default 'pending' check (status in ('pending','confirmed','processing','ready_for_collection','shipped','delivered','cancelled','completed')),
  subtotal numeric(12,2) not null check (subtotal >= 0),
  total numeric(12,2) not null check (total >= 0),
  payment_mode text not null default 'demo' check (payment_mode = 'demo'),
  payment_status text not null default 'pending',
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''), new.email)
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.profiles p where p.id = (select auth.uid()) and p.role = 'admin' and p.status = 'active');
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

alter table public.profiles enable row level security;
alter table public.vendors enable row level security;
alter table public.products enable row level security;
alter table public.wishlist enable row level security;
alter table public.orders enable row level security;

drop policy if exists "profiles select own or admin" on public.profiles;
create policy "profiles select own or admin" on public.profiles for select to authenticated using (id = (select auth.uid()) or public.is_admin());
drop policy if exists "profiles update own nonprivileged fields" on public.profiles;
create policy "profiles update own or admin" on public.profiles for update to authenticated using (id = (select auth.uid()) or public.is_admin()) with check (id = (select auth.uid()) or public.is_admin());
drop policy if exists "vendors public approved or owner or admin" on public.vendors;
create policy "vendors public approved or owner or admin" on public.vendors for select to anon, authenticated using (status = 'approved' or owner_id = (select auth.uid()) or public.is_admin());
drop policy if exists "vendors owner can apply" on public.vendors;
create policy "vendors owner can apply" on public.vendors for insert to authenticated with check (owner_id = (select auth.uid()) and status = 'pending_review' and trusted = false);
drop policy if exists "vendors owner can update application" on public.vendors;
create policy "vendors owner can update application" on public.vendors for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()) and status = 'pending_review' and trusted = false);
drop policy if exists "products public approved or admin or owner" on public.products;
create policy "products public approved or admin or owner" on public.products for select to anon, authenticated using (status = 'approved' or public.is_admin() or exists(select 1 from public.vendors v where v.id = vendor_id and v.owner_id = (select auth.uid())));
drop policy if exists "wishlist owner access" on public.wishlist;
create policy "wishlist owner access" on public.wishlist for all to authenticated using (user_id = (select auth.uid()) or public.is_admin()) with check (user_id = (select auth.uid()) or public.is_admin());
drop policy if exists "orders customer or admin read" on public.orders;
create policy "orders customer or admin read" on public.orders for select to authenticated using (customer_id = (select auth.uid()) or public.is_admin());
-- No direct client insert/update policies for orders or products. Add trusted server-side functions before enabling checkout.

grant select on public.profiles, public.vendors, public.products, public.wishlist, public.orders to anon, authenticated;
grant update (full_name, avatar_url, updated_at) on public.profiles to authenticated;
grant insert, delete on public.wishlist to authenticated;

-- Admin bootstrap: after creating an owner account, run the following manually in SQL Editor,
-- replacing the UUID with that account's auth.users id. Never expose a service-role key in frontend code.
-- update public.profiles set role = 'admin' where id = 'REPLACE-WITH-AUTH-USER-UUID';
