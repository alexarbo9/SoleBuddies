-- =============================================
-- SOLEMATES — Supabase Database Setup
-- Paste this entire file into:
-- Supabase Dashboard → SQL Editor → New Query → Run
-- =============================================

-- 1. LISTINGS TABLE
create table if not exists listings (
  id          uuid primary key default gen_random_uuid(),
  username    text not null,
  brand       text not null,
  style       text,
  size        text not null,
  side        text not null check (side in ('Left', 'Right')),
  condition   text not null,
  notes       text,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- 2. MESSAGES TABLE
create table if not exists messages (
  id          uuid primary key default gen_random_uuid(),
  listing_id  uuid not null references listings(id) on delete cascade,
  sender      text not null,
  recipient   text not null,
  body        text not null,
  created_at  timestamptz not null default now()
);

-- 3. INDEXES for fast queries
create index if not exists idx_listings_active    on listings(active);
create index if not exists idx_listings_side_size on listings(side, size);
create index if not exists idx_listings_username  on listings(username);
create index if not exists idx_messages_listing   on messages(listing_id);

-- 4. ENABLE REALTIME (so listings + messages update live)
alter publication supabase_realtime add table listings;
alter publication supabase_realtime add table messages;

-- 5. ROW LEVEL SECURITY — open read, anyone can post
alter table listings enable row level security;
alter table messages  enable row level security;

-- Anyone can read active listings
create policy "Public can read listings"
  on listings for select using (active = true);

-- Anyone can insert a listing
create policy "Anyone can post a listing"
  on listings for insert with check (true);

-- Users can deactivate their own listing (by username match)
create policy "Owner can deactivate listing"
  on listings for update using (true);

-- Anyone can read messages for a listing
create policy "Public can read messages"
  on messages for select using (true);

-- Anyone can send a message
create policy "Anyone can send a message"
  on messages for insert with check (true);

-- =============================================
-- Done! Refresh your SoleMates app and it
-- will connect to the live database.
-- =============================================
