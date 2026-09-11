-- =================================================================
-- FIX: "Error fetching profile: {}"
--
-- Your account exists in Authentication but has no profile row, so
-- the portal cannot tell which company you belong to.
--
-- Run SUPABASE-RUN-THIS.sql FIRST. Then paste this whole file into
-- Supabase -> SQL Editor -> New query and press RUN.
--
-- It links every existing user to a company, creates the company if
-- it does not exist, and gives them the starting checklist.
-- Safe to run more than once.
-- =================================================================

do $$
declare
  u record;
  new_client_id uuid;
  org_name text;
  person_name text;
begin
  for u in select id, email, raw_user_meta_data from auth.users loop

    -- skip anyone who already has a profile
    if exists (select 1 from profiles where id = u.id) then
      continue;
    end if;

    org_name := coalesce(
      nullif(u.raw_user_meta_data ->> 'company', ''),
      initcap(split_part(split_part(u.email, '@', 2), '.', 1))
    );
    person_name := coalesce(
      nullif(u.raw_user_meta_data ->> 'full_name', ''),
      initcap(replace(split_part(u.email, '@', 1), '.', ' '))
    );

    -- reuse the company if one with that name already exists
    select id into new_client_id from clients where name = org_name limit 1;
    if new_client_id is null then
      insert into clients (name) values (org_name) returning id into new_client_id;
    end if;

    insert into profiles (id, client_id, full_name)
    values (u.id, new_client_id, person_name);

    -- starting Selection Questionnaire checklist
    if not exists (select 1 from compliance_items where client_id = new_client_id) then
      insert into compliance_items (client_id, label, done, sort) values
        (new_client_id, 'Employer''s liability insurance (£5m minimum)', false, 1),
        (new_client_id, 'Two years of audited financial accounts',        false, 2),
        (new_client_id, 'Health & Safety policy signed within 12 months', false, 3),
        (new_client_id, 'Modern Slavery statement published',             false, 4),
        (new_client_id, 'Equal opportunities & diversity policy',         false, 5),
        (new_client_id, 'Environmental / carbon reduction plan',          false, 6);
    end if;

    raise notice 'Linked % to %', u.email, org_name;
  end loop;
end $$;

-- Check it worked — you should see one row per user, with a company name.
select p.full_name, c.name as company, u.email
from profiles p
join clients c on c.id = p.client_id
join auth.users u on u.id = p.id;

-- =================================================================
-- OPTIONAL: rename the company to what you actually want it called
-- (the automatic version guesses from the email domain).
--
--   update clients set name = 'Testing 123 Ltd'
--   where name = 'Gmail';
--
-- OPTIONAL: give yourself some sample work to look at.
-- Replace <client id> with the id from the query above, or use
-- Table Editor which lets you pick the client from a dropdown.
--
--   insert into bids (client_id, title, buyer, deadline, value, status, stage, sort)
--   values ('<client id>', 'NHS Facilities Framework',
--           'NHS Shared Business Services', '24 Aug 2026',
--           '£1.4m / 4 yrs', 'Drafting', 2, 1);
--
--   insert into tasks (client_id, label, due, sort)
--   values ('<client id>', 'Upload updated Health & Safety Policy', 'Due 20 Aug', 1);
-- =================================================================
