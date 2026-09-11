-- =================================================================
-- MARHANA & CO CLIENT PORTAL — COMPLETE SETUP
--
-- This is the ONLY thing you need to run. Copy this whole file,
-- paste it into Supabase → SQL Editor → New query, press RUN.
--
-- Safe to run more than once. If you already ran the older
-- schema file, running this on top of it is fine.
--
-- After this, adding a client is ONE action: invite them under
-- Authentication → Users. Everything else happens automatically.
-- =================================================================

-- ---------- TABLES ----------
create table if not exists clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);

create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  client_id uuid references clients on delete cascade,
  full_name text,
  created_at timestamptz default now()
);

create table if not exists bids (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  title text not null, buyer text, deadline text, value text,
  status text default 'Drafting', stage int default 0, sort int default 0,
  created_at timestamptz default now()
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  label text not null, due text, done boolean default false, sort int default 0
);

create table if not exists compliance_items (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  label text not null, done boolean default false, sort int default 0
);

create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  name text not null, folder text default 'Company Policies',
  version text default 'Current', size_label text, storage_path text,
  created_at timestamptz default now()
);

create table if not exists quotes (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  title text not null, detail text, amount text,
  accepted boolean default false, accepted_at timestamptz, sort int default 0
);

create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  ref text not null, issued text, amount text,
  status text default 'Due', sort int default 0
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  bid_id uuid references bids on delete cascade,
  body text not null, from_client boolean default true, author text,
  created_at timestamptz default now()
);

-- ---------- WHO IS THE SIGNED-IN USER? ----------
create or replace function current_client_id()
returns uuid language sql stable security definer set search_path = public as $$
  select client_id from profiles where id = auth.uid()
$$;

-- ---------- SECURITY: each client sees ONLY their own rows ----------
alter table clients          enable row level security;
alter table profiles         enable row level security;
alter table bids             enable row level security;
alter table tasks            enable row level security;
alter table compliance_items enable row level security;
alter table documents        enable row level security;
alter table quotes           enable row level security;
alter table invoices         enable row level security;
alter table messages         enable row level security;

drop policy if exists "own profile"   on profiles;
drop policy if exists "own client"    on clients;
drop policy if exists "read bids"     on bids;
drop policy if exists "read tasks"    on tasks;
drop policy if exists "read checks"   on compliance_items;
drop policy if exists "read docs"     on documents;
drop policy if exists "read quotes"   on quotes;
drop policy if exists "read invoices" on invoices;
drop policy if exists "read messages" on messages;
drop policy if exists "tick tasks"    on tasks;
drop policy if exists "tick checks"   on compliance_items;
drop policy if exists "accept quotes" on quotes;
drop policy if exists "upload docs"   on documents;
drop policy if exists "send messages" on messages;

create policy "own profile" on profiles for select using (id = auth.uid());
create policy "own client"  on clients  for select using (id = current_client_id());

create policy "read bids"     on bids             for select using (client_id = current_client_id());
create policy "read tasks"    on tasks            for select using (client_id = current_client_id());
create policy "read checks"   on compliance_items for select using (client_id = current_client_id());
create policy "read docs"     on documents        for select using (client_id = current_client_id());
create policy "read quotes"   on quotes           for select using (client_id = current_client_id());
create policy "read invoices" on invoices         for select using (client_id = current_client_id());
create policy "read messages" on messages         for select using (client_id = current_client_id());

create policy "tick tasks"    on tasks            for update using (client_id = current_client_id()) with check (client_id = current_client_id());
create policy "tick checks"   on compliance_items for update using (client_id = current_client_id()) with check (client_id = current_client_id());
create policy "accept quotes" on quotes           for update using (client_id = current_client_id()) with check (client_id = current_client_id());
create policy "upload docs"   on documents        for insert with check (client_id = current_client_id());
create policy "send messages" on messages         for insert with check (client_id = current_client_id() and from_client = true);

-- ---------- FILE STORAGE ----------
insert into storage.buckets (id, name, public)
values ('client-documents', 'client-documents', false)
on conflict (id) do nothing;

drop policy if exists "read own files"  on storage.objects;
drop policy if exists "write own files" on storage.objects;

create policy "read own files" on storage.objects for select using (
  bucket_id = 'client-documents' and (storage.foldername(name))[1] = current_client_id()::text
);
create policy "write own files" on storage.objects for insert with check (
  bucket_id = 'client-documents' and (storage.foldername(name))[1] = current_client_id()::text
);

-- =================================================================
-- AUTOMATIC CLIENT SET-UP
-- When you invite a user, this creates their organisation, links
-- them to it, and gives them a starting compliance checklist.
-- =================================================================
create or replace function handle_new_portal_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  new_client_id uuid;
  org_name text;
  person_name text;
begin
  -- Company name: taken from the invite's metadata if you set it,
  -- otherwise from their email domain (acme.co.uk -> Acme).
  org_name := coalesce(
    nullif(new.raw_user_meta_data ->> 'company', ''),
    initcap(split_part(split_part(new.email, '@', 2), '.', 1))
  );
  person_name := coalesce(
    nullif(new.raw_user_meta_data ->> 'full_name', ''),
    initcap(replace(split_part(new.email, '@', 1), '.', ' '))
  );

  insert into clients (name) values (org_name) returning id into new_client_id;
  insert into profiles (id, client_id, full_name) values (new.id, new_client_id, person_name);

  -- Standard Selection Questionnaire checklist, ready to work through
  insert into compliance_items (client_id, label, done, sort) values
    (new_client_id, 'Employer''s liability insurance (£5m minimum)', false, 1),
    (new_client_id, 'Two years of audited financial accounts',        false, 2),
    (new_client_id, 'Health & Safety policy signed within 12 months', false, 3),
    (new_client_id, 'Modern Slavery statement published',             false, 4),
    (new_client_id, 'Equal opportunities & diversity policy',         false, 5),
    (new_client_id, 'Environmental / carbon reduction plan',          false, 6);

  return new;
end;
$$;

drop trigger if exists on_portal_user_created on auth.users;
create trigger on_portal_user_created
  after insert on auth.users
  for each row execute function handle_new_portal_user();

-- =================================================================
-- DONE.
--
-- To add a client:
--   Authentication → Users → Add user → Send invitation
--   (optionally, under User Metadata, add:
--       { "company": "Ashworth & Vale Ltd", "full_name": "Alan Vale" } )
--
-- They set a password from the email, sign in at /portal, and see
-- their own empty dashboard with the checklist ready.
--
-- To add work for them, use Table Editor (a spreadsheet view):
--   bids     → New row. Fill title, buyer, deadline, value.
--              status: Drafting | Awaiting Review | Client Sign-off | Submitted
--              stage:  0 Kick-off  1 Storyboarding  2 Drafting
--                      3 Quality Assurance  4 Client Sign-off  5 Submission
--   tasks    → New row. label + due. Appears on their to-do list.
--   quotes   → New row. title, detail, amount. They can accept it.
--   invoices → New row. ref, issued, amount, status.
--   messages → New row. body, and set from_client to FALSE for your replies.
--
-- In every case pick the client_id from the dropdown — Table Editor
-- lists your clients by name, so there are no ids to copy.
-- =================================================================
