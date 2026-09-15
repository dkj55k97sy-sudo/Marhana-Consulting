-- ============================================================
-- Marhana & Co Consulting — admin console access
-- Run this in the SAME Supabase project as supabase-schema.sql
-- (SQL Editor → New query → paste this whole file → Run).
--
-- What this does: lets a flagged "admin" portal user read and
-- write every client's data (clients, bids, tasks, compliance
-- items, documents, quotes, invoices, messages) through the
-- normal anon key + Supabase Auth session — the same way the
-- client portal already reads its own rows. Nothing here weakens
-- client isolation: clients keep exactly the access they had
-- before, admins get an additional, separate set of policies.
-- ============================================================

-- 1. Flag on profiles: is this portal user staff, not a client?
alter table profiles add column if not exists is_admin boolean not null default false;

-- 2. Helper used by every admin policy below. security definer
--    so checking "am I admin?" doesn't recurse into profiles' own
--    row-level security while that security is being evaluated.
create or replace function is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from profiles where id = auth.uid()), false)
$$;

-- 3. Admins can see every profile and every client.
create policy "admin read profiles"  on profiles for select using (is_admin());
create policy "admin read clients"   on clients  for select using (is_admin());
create policy "admin insert clients" on clients  for insert with check (is_admin());
create policy "admin update clients" on clients  for update using (is_admin()) with check (is_admin());
create policy "admin delete clients" on clients  for delete using (is_admin());

-- 3b. Admins can link a portal user to a client (invite acceptance).
create policy "admin insert profiles" on profiles for insert with check (is_admin());
create policy "admin update profiles" on profiles for update using (is_admin()) with check (is_admin());

-- 4. Full admin CRUD on every client-scoped table.
create policy "admin read bids"    on bids for select using (is_admin());
create policy "admin insert bids"  on bids for insert with check (is_admin());
create policy "admin update bids"  on bids for update using (is_admin()) with check (is_admin());
create policy "admin delete bids"  on bids for delete using (is_admin());

create policy "admin read tasks"    on tasks for select using (is_admin());
create policy "admin insert tasks"  on tasks for insert with check (is_admin());
create policy "admin update tasks"  on tasks for update using (is_admin()) with check (is_admin());
create policy "admin delete tasks"  on tasks for delete using (is_admin());

create policy "admin read checks"    on compliance_items for select using (is_admin());
create policy "admin insert checks"  on compliance_items for insert with check (is_admin());
create policy "admin update checks"  on compliance_items for update using (is_admin()) with check (is_admin());
create policy "admin delete checks"  on compliance_items for delete using (is_admin());

create policy "admin read docs"    on documents for select using (is_admin());
create policy "admin insert docs"  on documents for insert with check (is_admin());
create policy "admin update docs"  on documents for update using (is_admin()) with check (is_admin());
create policy "admin delete docs"  on documents for delete using (is_admin());

create policy "admin read quotes"    on quotes for select using (is_admin());
create policy "admin insert quotes"  on quotes for insert with check (is_admin());
create policy "admin update quotes"  on quotes for update using (is_admin()) with check (is_admin());
create policy "admin delete quotes"  on quotes for delete using (is_admin());

create policy "admin read invoices"    on invoices for select using (is_admin());
create policy "admin insert invoices"  on invoices for insert with check (is_admin());
create policy "admin update invoices"  on invoices for update using (is_admin()) with check (is_admin());
create policy "admin delete invoices"  on invoices for delete using (is_admin());

create policy "admin read messages"   on messages for select using (is_admin());
create policy "admin insert messages" on messages for insert with check (is_admin());
create policy "admin update messages" on messages for update using (is_admin()) with check (is_admin());
create policy "admin delete messages" on messages for delete using (is_admin());

-- 5. Admins can read every client's uploaded files in Storage too.
create policy "admin read all files" on storage.objects
  for select using (bucket_id = 'client-documents' and is_admin());

-- ============================================================
-- Make yourself an admin (run once, after the block above).
--
-- 1. Authentication → Users → Invite user (your own email), or
--    use an account you already created there.
-- 2. Copy that user's id from the Users table, then:
--
--   insert into profiles (id, full_name, is_admin)
--   values ('<your-auth-user-id>', 'Your Name', true)
--   on conflict (id) do update set is_admin = true;
--
--    client_id stays null — an admin isn't tied to one client.
-- ============================================================
