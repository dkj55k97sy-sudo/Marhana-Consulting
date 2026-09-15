-- ============================================================
-- Marhana & Co Consulting — unread message tracking for admin
-- Run this in the SAME Supabase project as the earlier migrations
-- (SQL Editor → New query → paste this whole file → Run).
--
-- What this does: when a client sends a message from the client
-- portal, it's already reaching the same database the admin
-- console reads — this just adds a read/unread flag so it's
-- impossible to miss. The admin console shows an unread count on
-- the Messages nav item and next to each client/thread, and clears
-- it the moment that thread is opened.
-- ============================================================

alter table messages add column if not exists read_at timestamptz;

-- No new RLS policy needed: SUPABASE-ADMIN-ACCESS.sql already grants
-- admins UPDATE on messages, which covers writing this column too.
