-- =============================================
-- SoleBuddies — Listing photos (free-tier friendly caps via bucket limits)
-- Run in Supabase → SQL Editor after 05 listings columns.sql
-- =============================================

alter table listings add column if not exists photo_urls text[] not null default '{}';

-- Public bucket (~2 MB, JPEG/WebP only). Adjust in Dashboard if needed.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'listing-photos',
  'listing-photos',
  true,
  2097152,
  array['image/jpeg', 'image/webp']::text[]
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Path convention: listing-photos/{auth.uid()}/…  (enforce first segment = user id).
-- Requires storage.foldername() (standard on Supabase). If policy creation errors, replace
-- (storage.foldername(name))[1] with split_part(name, '/', 1) after confirming object path layout.

drop policy if exists "Listing photos read public" on storage.objects;
create policy "Listing photos read public"
  on storage.objects for select to public
  using (bucket_id = 'listing-photos');

drop policy if exists "Listing photos upload own prefix" on storage.objects;
create policy "Listing photos upload own prefix"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'listing-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Listing photos update own prefix" on storage.objects;
create policy "Listing photos update own prefix"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'listing-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'listing-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Listing photos delete own prefix" on storage.objects;
create policy "Listing photos delete own prefix"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'listing-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
