-- ============================================================
-- Marhana & Co Consulting — client-editable profile
-- Run this in the SAME Supabase project as supabase-schema.sql
-- and SUPABASE-ADMIN-ACCESS.sql (SQL Editor → New query → paste
-- this whole file → Run).
--
-- What this does: adds business-profile columns to `clients` and
-- lets a signed-in client edit their own name and their own
-- business's details from the new Profile tab in the portal —
-- without opening up anyone else's data. Admins already have full
-- access to these columns from SUPABASE-ADMIN-ACCESS.sql.
-- ============================================================

-- 1. New columns on clients — nullable, so existing rows are unaffected.
alter table clients add column if not exists sector text;
alter table clients add column if not exists contact_name text;
alter table clients add column if not exists contact_email text;
alter table clients add column if not exists contact_phone text;

-- 2. A client may update their own business's row (name and the
--    new profile fields) — but only their own, enforced the same
--    way every other client policy in this project is: by
--    current_client_id(), never by an id sent from the browser.
create policy "update own client" on clients
  for update using (id = current_client_id()) with check (id = current_client_id());

-- 3. A client may update their own portal-user row (their name).
--    There was previously no update policy here at all for clients.
create policy "update own profile" on profiles
  for update using (id = auth.uid()) with check (id = auth.uid());
