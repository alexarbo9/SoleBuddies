-- =============================================
-- SoleBuddies — Listings columns used by index.html
-- Run in Supabase → SQL Editor after 03 + 04.
-- =============================================

alter table listings add column if not exists gender   text;
alter table listings add column if not exists country  text;
alter table listings add column if not exists state    text;
alter table listings add column if not exists traded   boolean not null default false;

-- RPC from browser after trade completes
grant execute on function increment_trade_count(text) to authenticated;
