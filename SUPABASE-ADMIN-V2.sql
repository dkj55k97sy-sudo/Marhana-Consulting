-- ============================================================
-- Marhana & Co Consulting — v2 admin console schema
-- Run this in the SAME Supabase project as the earlier migrations
-- (SQL Editor → New query → paste this whole file → Run).
--
-- This adds what the full admin console design needs: client
-- archiving, a numeric bid value, the twelve-required-document
-- approval workflow, and staff-only internal notes. It does not
-- touch anything the client portal already reads or writes —
-- existing client-uploaded documents (free-form, in their own
-- folders) are untouched; the new required-document rows this
-- migration creates are tagged with a `category` and are excluded
-- from the client portal's own document list (see the matching
-- portal.html change that ships alongside this).
-- ============================================================

-- 1. Client archiving.
alter table clients add column if not exists archived boolean not null default false;
alter table clients add column if not exists archived_at timestamptz;

-- 2. A real numeric bid value (existing free-text `value` column is
--    kept as-is — the admin console writes a formatted string there
--    too, so the client portal's bid cards keep showing something
--    sensible) and the closing outcome.
alter table bids add column if not exists value_gbp numeric not null default 0;
alter table bids add column if not exists outcome text;

-- 3. Document approval workflow. `status` is missing/pending/approved
--    — "expiring" and "expired" are derived from expiry_date at read
--    time, never stored (so they can't go stale). `category` is set
--    only on the twelve-required-document rows this migration
--    creates; a client's own ad-hoc uploads leave it null.
alter table documents add column if not exists category text;
alter table documents add column if not exists status text not null default 'missing';
alter table documents add column if not exists expiry_date date;
alter table documents add column if not exists review_note text;
alter table documents add column if not exists status_changed_at timestamptz;

-- 4. Every client gets the same twelve required-document rows the
--    moment they're created, starting as "missing".
create or replace function seed_required_documents()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  doc_name text;
  required_docs text[] := array[
    'Insurance certificates', 'Health & safety policy', 'Accreditations (CHAS, SafeContractor)',
    'Company accounts', 'Method statements', 'Risk assessments', 'Case studies / past projects',
    'Staff CVs', 'Signed contracts', 'Completed bid submissions', 'ID / right to work',
    'Quality certifications (ISO)'
  ];
begin
  foreach doc_name in array required_docs loop
    insert into documents (client_id, name, category, status)
    values (new.id, doc_name, doc_name, 'missing');
  end loop;
  return new;
end;
$$;

drop trigger if exists trg_seed_required_documents on clients;
create trigger trg_seed_required_documents
  after insert on clients
  for each row execute function seed_required_documents();

-- 4b. Backfill: give any client created before this migration the
--     same twelve rows, without duplicating anything already there.
do $$
declare
  c record;
  doc_name text;
  required_docs text[] := array[
    'Insurance certificates', 'Health & safety policy', 'Accreditations (CHAS, SafeContractor)',
    'Company accounts', 'Method statements', 'Risk assessments', 'Case studies / past projects',
    'Staff CVs', 'Signed contracts', 'Completed bid submissions', 'ID / right to work',
    'Quality certifications (ISO)'
  ];
begin
  for c in select id from clients loop
    foreach doc_name in array required_docs loop
      if not exists (select 1 from documents where client_id = c.id and category = doc_name) then
        insert into documents (client_id, name, category, status) values (c.id, doc_name, doc_name, 'missing');
      end if;
    end loop;
  end loop;
end $$;

-- 5. Internal notes. Staff only — deliberately no client-facing
--    policy on this table at all, matching how client_notes is
--    documented everywhere else in this project.
create table if not exists client_notes (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  body text not null,
  author text,
  created_at timestamptz default now()
);
alter table client_notes enable row level security;
create policy "admin read notes"   on client_notes for select using (is_admin());
create policy "admin insert notes" on client_notes for insert with check (is_admin());
create policy "admin update notes" on client_notes for update using (is_admin()) with check (is_admin());
create policy "admin delete notes" on client_notes for delete using (is_admin());
