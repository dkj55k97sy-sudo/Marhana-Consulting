-- ============================================================
-- Marhana & Co — Portal v2 migration
-- Clients management · Bid pipeline · Messaging · Audit trail
--
-- Safe to run on top of supabase-schema.sql and
-- SUPABASE-DOCUMENTS-MIGRATION.sql. Idempotent — re-running is fine.
-- Paste the whole file into Supabase → SQL Editor → Run.
-- ============================================================


-- ------------------------------------------------------------
-- 0. Admin role helper
--    (SUPABASE-DOCUMENTS-MIGRATION.sql may already have added this;
--     both statements are guarded.)
-- ------------------------------------------------------------
alter table profiles add column if not exists role text default 'client';
alter table profiles add column if not exists email text;

create or replace function is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select role = 'admin' from profiles where id = auth.uid()), false)
$$;


-- ------------------------------------------------------------
-- 1. Clients: the fields the Clients screen edits
-- ------------------------------------------------------------
alter table clients add column if not exists sector          text;
alter table clients add column if not exists contact_name    text;
alter table clients add column if not exists contact_email   text;
alter table clients add column if not exists contact_phone   text;
alter table clients add column if not exists archived        boolean default false;
alter table clients add column if not exists archived_at     timestamptz;
alter table clients add column if not exists last_activity_at timestamptz default now();

-- Internal notes — admin only, never visible to the client
create table if not exists client_notes (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  body text not null,
  author_id uuid references auth.users on delete set null,
  author_name text,
  created_at timestamptz default now()
);
create index if not exists client_notes_client_idx on client_notes (client_id, created_at desc);

-- Portal invitations
create table if not exists client_invites (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients on delete cascade,
  email text not null,
  invited_by uuid references auth.users on delete set null,
  invited_at timestamptz default now(),
  accepted_at timestamptz,
  status text default 'sent'          -- sent | accepted | revoked
);
create index if not exists client_invites_client_idx on client_invites (client_id, invited_at desc);


-- ------------------------------------------------------------
-- 2. Bids: named pipeline stages
--    Stage order matches the admin board, left to right.
-- ------------------------------------------------------------
create table if not exists bid_stages (
  position int primary key,
  name text not null unique,
  is_closed boolean default false
);

insert into bid_stages (position, name, is_closed) values
  (0, 'Opportunity',     false),
  (1, 'Qualifying',      false),
  (2, 'Drafting',        false),
  (3, 'Internal review', false),
  (4, 'Submitted',       false),
  (5, 'Outcome',         true)
on conflict (position) do update set name = excluded.name, is_closed = excluded.is_closed;

alter table bids add column if not exists deadline_date date;
alter table bids add column if not exists value_pence   bigint;
alter table bids add column if not exists outcome       text;         -- Won | Lost | Withdrawn | null
alter table bids add column if not exists outcome_at    timestamptz;
alter table bids add column if not exists owner_id      uuid references auth.users on delete set null;
alter table bids add column if not exists updated_at    timestamptz default now();

-- Backfill the typed columns from the original free-text ones, once.
update bids set deadline_date = nullif(deadline, '')::date
  where deadline_date is null and deadline ~ '^\d{4}-\d{2}-\d{2}$';
update bids set value_pence = (regexp_replace(coalesce(value, ''), '[^0-9]', '', 'g'))::bigint * 100
  where value_pence is null and value ~ '\d';

-- Keep bids.stage inside the defined range
alter table bids drop constraint if exists bids_stage_range;
alter table bids add constraint bids_stage_range check (stage between 0 and 5);

create index if not exists bids_client_idx   on bids (client_id, stage);
create index if not exists bids_deadline_idx on bids (deadline_date);


-- ------------------------------------------------------------
-- 3. Messaging: one thread per bid, plus a general thread
--    per client. A thread is identified by (client_id, bid_id)
--    where bid_id null = the general thread.
-- ------------------------------------------------------------
alter table messages add column if not exists author_id  uuid references auth.users on delete set null;
alter table messages add column if not exists read_at    timestamptz;   -- when the *other* side read it
alter table messages add column if not exists attachment_path text;

create index if not exists messages_thread_idx on messages (client_id, bid_id, created_at desc);
create index if not exists messages_unread_idx on messages (client_id, from_client, read_at);

-- Thread summary: one row per conversation, newest activity first.
create or replace view message_threads as
select
  m.client_id,
  m.bid_id,
  c.name                                            as client_name,
  c.contact_name,
  coalesce(b.title, 'General')                      as thread_label,
  count(*)                                          as message_count,
  count(*) filter (where m.from_client and m.read_at is null)      as unread_for_admin,
  count(*) filter (where not m.from_client and m.read_at is null)  as unread_for_client,
  max(m.created_at)                                 as last_message_at,
  (array_agg(m.body order by m.created_at desc))[1] as last_body,
  (array_agg(m.from_client order by m.created_at desc))[1] as last_from_client
from messages m
join clients c on c.id = m.client_id
left join bids b on b.id = m.bid_id
group by m.client_id, m.bid_id, c.name, c.contact_name, b.title;

-- Mark a whole thread read for whoever is calling.
create or replace function mark_thread_read(p_client_id uuid, p_bid_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  update messages
     set read_at = now()
   where client_id = p_client_id
     and (bid_id = p_bid_id or (p_bid_id is null and bid_id is null))
     and read_at is null
     -- admin clears client messages; a client clears ours
     and from_client = is_admin();
end;
$$;


-- ------------------------------------------------------------
-- 4. Audit trail — who changed what, when
-- ------------------------------------------------------------
create table if not exists audit_log (
  id bigserial primary key,
  at timestamptz default now(),
  actor_id uuid,
  actor_email text,
  action text not null,             -- insert | update | delete
  table_name text not null,
  row_id uuid,
  client_id uuid,
  summary text,
  before jsonb,
  after jsonb
);
create index if not exists audit_log_client_idx on audit_log (client_id, at desc);
create index if not exists audit_log_table_idx  on audit_log (table_name, at desc);

create or replace function audit_capture()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_row  jsonb := to_jsonb(coalesce(new, old));
  v_cid  uuid;
begin
  v_cid := nullif(v_row->>'client_id', '')::uuid;
  if v_cid is null and tg_table_name = 'clients' then
    v_cid := nullif(v_row->>'id', '')::uuid;
  end if;

  insert into audit_log (actor_id, actor_email, action, table_name, row_id, client_id, summary, before, after)
  values (
    auth.uid(),
    (select email from profiles where id = auth.uid()),
    lower(tg_op),
    tg_table_name,
    nullif(v_row->>'id', '')::uuid,
    v_cid,
    coalesce(v_row->>'title', v_row->>'name', v_row->>'ref', v_row->>'label', tg_table_name),
    case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) end,
    case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) end
  );
  return coalesce(new, old);
end;
$$;

do $$
declare t text;
begin
  foreach t in array array['clients','bids','documents','messages','client_notes','client_invites','invoices','quotes']
  loop
    if exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = t) then
      execute format('drop trigger if exists audit_%1$s on %1$I', t);
      execute format('create trigger audit_%1$s after insert or update or delete on %1$I
                      for each row execute function audit_capture()', t);
    end if;
  end loop;
end $$;

-- Touch last_activity_at whenever anything happens on a client
create or replace function touch_client_activity()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update clients set last_activity_at = now()
   where id = coalesce(new.client_id, old.client_id);
  return coalesce(new, old);
end;
$$;

drop trigger if exists touch_activity_messages on messages;
create trigger touch_activity_messages after insert on messages
  for each row execute function touch_client_activity();

drop trigger if exists touch_activity_documents on documents;
create trigger touch_activity_documents after insert or update on documents
  for each row execute function touch_client_activity();


-- ------------------------------------------------------------
-- 5. Row-level security
--    Clients keep their existing read/write policies.
--    Admins get full access across every client.
-- ------------------------------------------------------------
alter table client_notes   enable row level security;
alter table client_invites enable row level security;
alter table bid_stages     enable row level security;
alter table audit_log      enable row level security;

-- Admin: everything, every table
do $$
declare t text;
begin
  foreach t in array array['clients','profiles','bids','tasks','compliance_items','documents',
                           'quotes','invoices','messages','client_notes','client_invites','audit_log']
  loop
    if exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = t) then
      execute format('drop policy if exists "admin all %1$s" on %1$I', t);
      execute format('create policy "admin all %1$s" on %1$I for all
                      using (is_admin()) with check (is_admin())', t);
    end if;
  end loop;
end $$;

-- Stage names are readable by everyone signed in
drop policy if exists "read stages" on bid_stages;
create policy "read stages" on bid_stages for select using (auth.uid() is not null);

-- Clients may reply in their own threads (insert policy already exists);
-- allow them to mark our messages read.
drop policy if exists "client marks read" on messages;
create policy "client marks read" on messages for update
  using (client_id = current_client_id() and from_client = false)
  with check (client_id = current_client_id() and from_client = false);

-- Internal notes and the audit log are admin-only: no client policy at all.

-- Admin storage access to every client folder
drop policy if exists "admin read files" on storage.objects;
create policy "admin read files" on storage.objects for select
  using (bucket_id = 'client-documents' and is_admin());

drop policy if exists "admin write files" on storage.objects;
create policy "admin write files" on storage.objects for insert
  with check (bucket_id = 'client-documents' and is_admin());


-- ------------------------------------------------------------
-- 6. Dashboard views the admin screens read from
-- ------------------------------------------------------------

-- One row per client: doc completion, open bids, unread messages.
create or replace view admin_client_overview as
select
  c.id,
  c.name,
  c.sector,
  c.contact_name,
  c.contact_email,
  c.archived,
  c.last_activity_at,
  (select count(*) from document_types dt where dt.required)                     as docs_required,
  (select count(*) from documents d
     where d.client_id = c.id and d.status = 'approved')                         as docs_approved,
  (select count(*) from bids b where b.client_id = c.id and b.stage < 5)         as open_bids,
  (select count(*) from messages m
     where m.client_id = c.id and m.from_client and m.read_at is null)           as unread_messages,
  (select count(*) from client_invites i
     where i.client_id = c.id and i.status = 'accepted')                         as portal_users
from clients c;

-- Pipeline rows with stage names resolved, soonest deadline first.
create or replace view admin_bid_pipeline as
select
  b.id,
  b.client_id,
  c.name as client_name,
  b.title,
  b.buyer,
  b.deadline_date,
  b.value_pence,
  b.stage,
  s.name as stage_name,
  s.is_closed,
  b.outcome,
  (b.deadline_date - current_date) as days_left,
  (select count(*) from messages m
     where m.bid_id = b.id and m.from_client and m.read_at is null) as unread_messages
from bids b
join clients c on c.id = b.client_id
left join bid_stages s on s.position = b.stage
order by b.deadline_date nulls last;


-- ============================================================
-- 7. Make yourself admin — edit the email, then run this line
-- ============================================================
-- update profiles
--    set role = 'admin',
--        email = (select email from auth.users where id = profiles.id)
--  where id = (select id from auth.users where email = 'you@marhanaconsultancy.com');

-- Sanity checks:
--   select * from bid_stages order by position;
--   select * from admin_client_overview order by name;
--   select * from message_threads order by last_message_at desc;
