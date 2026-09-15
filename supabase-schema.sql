-- ============================================================
-- Marhana & Co Consulting — client portal database
-- Paste this whole file into the Supabase SQL Editor and Run.
-- ============================================================

-- 1. Client organisations -----------------------------------
create table if not exists clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sector text,
  contact_name text,
  contact_email text,
  contact_phone text,
  created_at timestamptz default now()
);

-- 2. Portal users, each tied to one client -------------------
create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  client_id uuid references clients on delete cascade,
  full_name text,
  created_at timestamptz default now()
);

-- Helper: which client does the signed-in user belong to?
create or replace function current_client_id()
returns uuid language sql stable security definer set search_path = public as $$
  select client_id from profiles where id = auth.uid()
$$;

-- 3. Bids ----------------------------------------------------
create table if not exists bids (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  title text not null,
  buyer text,
  deadline text,
  value text,
  status text default 'Drafting',
  stage int default 0,              -- 0..5 across the six milestones
  sort int default 0,
  created_at timestamptz default now()
);

-- 4. Client to-do list ---------------------------------------
create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  label text not null,
  due text,
  done boolean default false,
  sort int default 0
);

-- 5. Compliance / SQ checklist -------------------------------
create table if not exists compliance_items (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  label text not null,
  done boolean default false,
  sort int default 0
);

-- 6. Document vault ------------------------------------------
create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  name text not null,
  folder text default 'Company Policies',
  version text default 'Current',
  size_label text,
  storage_path text,
  created_at timestamptz default now()
);

-- 7. Quotes --------------------------------------------------
create table if not exists quotes (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  title text not null,
  detail text,
  amount text,
  accepted boolean default false,
  accepted_at timestamptz,
  sort int default 0
);

-- 8. Invoices ------------------------------------------------
create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  ref text not null,
  issued text,
  amount text,
  status text default 'Due',
  sort int default 0
);

-- 9. Messages ------------------------------------------------
create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  bid_id uuid references bids on delete cascade,
  body text not null,
  from_client boolean default true,
  author text,
  read_at timestamptz,
  created_at timestamptz default now()
);

-- ============================================================
-- Row-level security: a client sees only their own rows.
-- ============================================================
alter table clients           enable row level security;
alter table profiles          enable row level security;
alter table bids              enable row level security;
alter table tasks             enable row level security;
alter table compliance_items  enable row level security;
alter table documents         enable row level security;
alter table quotes            enable row level security;
alter table invoices          enable row level security;
alter table messages          enable row level security;

create policy "own profile" on profiles
  for select using (id = auth.uid());

create policy "update own profile" on profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

create policy "own client" on clients
  for select using (id = current_client_id());

create policy "update own client" on clients
  for update using (id = current_client_id()) with check (id = current_client_id());

-- Read-only tables for the client
create policy "read bids"     on bids     for select using (client_id = current_client_id());
create policy "read invoices" on invoices for select using (client_id = current_client_id());
create policy "read docs"     on documents for select using (client_id = current_client_id());
create policy "read quotes"   on quotes   for select using (client_id = current_client_id());
create policy "read tasks"    on tasks    for select using (client_id = current_client_id());
create policy "read checks"   on compliance_items for select using (client_id = current_client_id());
create policy "read messages" on messages for select using (client_id = current_client_id());

-- Things the client is allowed to change
create policy "tick tasks" on tasks
  for update using (client_id = current_client_id()) with check (client_id = current_client_id());

create policy "tick checks" on compliance_items
  for update using (client_id = current_client_id()) with check (client_id = current_client_id());

create policy "accept quotes" on quotes
  for update using (client_id = current_client_id()) with check (client_id = current_client_id());

create policy "upload docs" on documents
  for insert with check (client_id = current_client_id());

create policy "send messages" on messages
  for insert with check (client_id = current_client_id() and from_client = true);

-- ============================================================
-- Storage: one private bucket, foldered by client id.
-- ============================================================
insert into storage.buckets (id, name, public)
values ('client-documents', 'client-documents', false)
on conflict (id) do nothing;

create policy "read own files" on storage.objects
  for select using (
    bucket_id = 'client-documents'
    and (storage.foldername(name))[1] = current_client_id()::text
  );

create policy "write own files" on storage.objects
  for insert with check (
    bucket_id = 'client-documents'
    and (storage.foldername(name))[1] = current_client_id()::text
  );

-- ============================================================
-- Onboarding a client (run once per client, editing the values)
-- ============================================================
-- 1. Create the organisation:
--      insert into clients (name) values ('Ashworth & Vale Ltd') returning id;
-- 2. Invite the user in Authentication → Users → Invite.
-- 3. Link the user to the organisation, using both ids:
--      insert into profiles (id, client_id, full_name)
--      values ('<auth-user-id>', '<client-id>', 'Alan Vale');
-- 4. Add their bids, tasks, quotes and invoices with the same client_id.
