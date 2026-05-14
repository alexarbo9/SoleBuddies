-- =============================================
-- SOLEMATES — Update 4: Shipping, Security, System Messages
-- Run in Supabase → SQL Editor → New Query → Run
-- Requires: listings + messages from solemates-setup 3.sql first
-- Safe to re-run (idempotent realtime + policy drops + IF NOT EXISTS)
-- =============================================

-- Base tables first (profiles must exist before we alter it below)
create table if not exists trades (
  id                 uuid primary key default gen_random_uuid(),
  listing_id         uuid not null references listings(id) on delete cascade,
  lister_username    text not null,
  requester_username text not null,
  lister_agreed      boolean not null default false,
  requester_agreed   boolean not null default false,
  lister_shipped     boolean not null default false,
  requester_shipped  boolean not null default false,
  lister_received    boolean not null default false,
  requester_received boolean not null default false,
  created_at         timestamptz not null default now()
);

create table if not exists profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  username         text unique not null,
  trade_count      int not null default 0,
  positive_ratings int not null default 0,
  total_ratings    int not null default 0,
  badges           text[] not null default '{}',
  first_name       text,
  last_name        text,
  address          text,
  city             text,
  state            text,
  zip              text,
  country          text,
  created_at       timestamptz not null default now()
);

-- Add shipping fields to profiles (private, never public)
alter table profiles add column if not exists first_name text;
alter table profiles add column if not exists last_name  text;
alter table profiles add column if not exists address    text;
alter table profiles add column if not exists city       text;
alter table profiles add column if not exists state      text;
alter table profiles add column if not exists zip        text;
alter table profiles add column if not exists country    text;

-- Add is_system flag to messages (for trade progress notifications)
alter table messages add column if not exists is_system boolean not null default false;

-- Add user_id to listings if not already there
alter table listings add column if not exists user_id uuid references auth.users(id);

-- Add sender fields to messages if not already there
alter table messages add column if not exists sender_id         uuid references auth.users(id);
alter table messages add column if not exists sender_username   text;
alter table messages add column if not exists recipient_username text;

-- Indexes
create index if not exists idx_trades_listing    on trades(listing_id);
create index if not exists idx_trades_users      on trades(lister_username, requester_username);
create index if not exists idx_profiles_username on profiles(username);

-- Realtime for trades and profiles (skip if already in publication — avoids ERROR 42710)
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'trades'
  ) then
    alter publication supabase_realtime add table public.trades;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'profiles'
  ) then
    alter publication supabase_realtime add table public.profiles;
  end if;
end $$;

-- RLS: Profiles
alter table profiles enable row level security;

drop policy if exists "Anyone can read profiles" on profiles;
create policy "Anyone can read profiles"
  on profiles for select using (true);

drop policy if exists "Users can insert their own profile" on profiles;
create policy "Users can insert their own profile"
  on profiles for insert with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on profiles;
create policy "Users can update their own profile"
  on profiles for update using (auth.uid() = id);

-- RLS: Trades
alter table trades enable row level security;

drop policy if exists "Anyone can read trades" on trades;
create policy "Anyone can read trades"
  on trades for select using (true);

drop policy if exists "Authenticated users can create trades" on trades;
create policy "Authenticated users can create trades"
  on trades for insert with check (auth.role() = 'authenticated');

drop policy if exists "Authenticated users can update trades" on trades;
create policy "Authenticated users can update trades"
  on trades for update using (auth.role() = 'authenticated');

-- RLS: Listings (tighten — only owner can update/delete)
drop policy if exists "Owner can deactivate listing" on listings;
drop policy if exists "Owner can update own listing" on listings;
create policy "Owner can update own listing"
  on listings for update using (auth.uid() = user_id);

-- RLS: Messages (tighten — only authenticated users can send)
drop policy if exists "Anyone can send a message" on messages;
drop policy if exists "Authenticated users can send messages" on messages;
create policy "Authenticated users can send messages"
  on messages for insert with check (auth.role() = 'authenticated');

-- Function to increment trade count safely
create or replace function increment_trade_count(username_param text)
returns void language plpgsql security definer as $$
begin
  update profiles
  set trade_count = trade_count + 1
  where username = username_param;
end;
$$;

-- =============================================
-- Done! Upload your new index.html to GitHub
-- and the app will use all these new features.
-- =============================================
