-- ============================================================
-- Marhana & Co — Documents module
-- Run this in Supabase → SQL Editor, after supabase-schema.sql.
-- Safe to run more than once.
-- ============================================================

-- 1. Admin role ----------------------------------------------
alter table profiles add column if not exists is_admin boolean default false;

create or replace function is_admin() returns boolean
  language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from profiles where id = auth.uid()), false)
$$;

-- 2. The twelve required document types ----------------------
create table if not exists document_types (
  id uuid primary key default gen_random_uuid(),
  label text not null unique,
  sort int default 0,
  requires_expiry boolean default false,
  guidance text
);

insert into document_types (label, sort, requires_expiry, guidance) values
  ('Insurance certificates',                    1,  true,  'Employers'' liability, public liability and professional indemnity.'),
  ('Health & safety policy',                    2,  true,  'Signed and dated, reviewed within the last 12 months.'),
  ('Accreditations (CHAS, SafeContractor)',     3,  true,  'Current certificate showing the expiry date.'),
  ('Company accounts',                          4,  false, 'Most recent two years, filed.'),
  ('Method statements',                         5,  false, 'Relevant to the work being bid for.'),
  ('Risk assessments',                          6,  true,  'Site or activity specific, reviewed annually.'),
  ('Case studies / past projects',              7,  false, 'Three comparable contracts with values and dates.'),
  ('Staff CVs',                                 8,  false, 'Key personnel named in the bid.'),
  ('Signed contracts',                          9,  false, 'Fully executed copies.'),
  ('Completed bid submissions',                10,  false, 'Final submitted version, for the record.'),
  ('ID / right to work',                       11,  true,  'For staff to be deployed on contract.'),
  ('Quality certifications (ISO)',             12,  true,  'ISO 9001 / 14001 / 45001 as applicable.')
on conflict (label) do nothing;

-- 3. Extend the document vault -------------------------------
alter table documents add column if not exists doc_type_id  uuid references document_types on delete set null;
alter table documents add column if not exists status       text default 'pending';
alter table documents add column if not exists expiry_date  date;
alter table documents add column if not exists review_note  text;
alter table documents add column if not exists reviewed_at  timestamptz;
alter table documents add column if not exists reviewed_by  uuid references auth.users on delete set null;
alter table documents add column if not exists uploaded_by  uuid references auth.users on delete set null;
alter table documents add column if not exists mime_type    text;
alter table documents add column if not exists size_bytes   bigint;

do $$ begin
  alter table documents add constraint documents_status_check
    check (status in ('pending', 'approved', 'rejected'));
exception when duplicate_object then null; end $$;

create index if not exists documents_client_type_idx on documents (client_id, doc_type_id, created_at desc);

-- 4. One row per client per required document -----------------
-- Everything the admin Documents page reads comes from here.
create or replace view client_document_status with (security_invoker = true) as
select
  c.id                as client_id,
  c.name              as client_name,
  t.id                as doc_type_id,
  t.label             as doc_label,
  t.sort              as doc_sort,
  t.requires_expiry,
  t.guidance,
  d.id                as document_id,
  d.name              as file_name,
  d.storage_path,
  d.created_at        as uploaded_at,
  d.expiry_date,
  d.review_note,
  d.size_bytes,
  case
    when d.id is null                                                     then 'missing'
    when d.status = 'rejected'                                            then 'rejected'
    when d.status = 'pending'                                             then 'pending'
    when d.expiry_date is not null and d.expiry_date < current_date       then 'expired'
    else 'approved'
  end as status,
  case when d.expiry_date is null then null
       else (d.expiry_date - current_date) end as days_until_expiry
from clients c
cross join document_types t
left join lateral (
  select * from documents dd
  where dd.client_id = c.id and dd.doc_type_id = t.id
  order by dd.created_at desc limit 1
) d on true;

-- 5. Who can do what -----------------------------------------
alter table document_types enable row level security;

drop policy if exists "anyone signed in reads doc types" on document_types;
create policy "anyone signed in reads doc types" on document_types
  for select using (auth.uid() is not null);

-- Admin gets full reach across every client.
do $$
declare t text;
begin
  foreach t in array array['clients','profiles','bids','tasks','compliance_items',
                           'documents','quotes','invoices','messages','document_types']
  loop
    execute format('drop policy if exists "admin full access" on %I', t);
    execute format('create policy "admin full access" on %I for all using (is_admin()) with check (is_admin())', t);
  end loop;
end $$;

-- A client may upload, but may never set its own status.
drop policy if exists "upload docs" on documents;
create policy "upload docs" on documents
  for insert with check (
    client_id = current_client_id()
    and status = 'pending'
    and reviewed_at is null
  );

-- 6. File storage --------------------------------------------
insert into storage.buckets (id, name, public)
values ('client-documents', 'client-documents', false)
on conflict (id) do nothing;

drop policy if exists "admin reads all files" on storage.objects;
create policy "admin reads all files" on storage.objects
  for select using (bucket_id = 'client-documents' and is_admin());

drop policy if exists "admin writes all files" on storage.objects;
create policy "admin writes all files" on storage.objects
  for insert with check (bucket_id = 'client-documents' and is_admin());

-- ============================================================
-- Make yourself an admin. Replace the email, then run:
--
--   update profiles set is_admin = true
--   where id = (select id from auth.users where email = 'you@marhanaconsulting.com');
-- ============================================================
