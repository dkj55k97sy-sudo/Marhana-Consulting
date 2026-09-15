# Making the admin console real

Short answer to "is the admin portal linked to the client portal": **it wasn't** — `Marhana
Portal Admin.dc.html` was a design mockup with no backend at all (see
`ENGINEER-HANDOFF.md`, section 2: "no persistence"). Nothing you clicked there was ever
saved anywhere, and it had no connection to the client portal or its data.

This adds a working admin console — `admin.html` — that reads and writes the **same**
Supabase database the live client portal (`portal.html`) already uses. They are now
genuinely connected: add a bid, tick a compliance item, or reply to a message as admin, and
the client sees it the moment they refresh their portal. Nothing needs syncing because
there's only one database.

---

## 1. Run one SQL file

In the Supabase project you already have connected (`supabase.com` → your `marhana-portal`
project → **SQL Editor** → **New query**):

1. Open `SUPABASE-ADMIN-ACCESS.sql` from this project, copy the whole file, paste it in, **Run**.

This adds an `is_admin` flag and a matching set of database rules so a flagged admin user
can read and write every client's data. It does not change anything about how clients see
their own data — that stays exactly as locked-down as before.

## 2. Make yourself an admin

1. **Authentication → Users → Invite user** — use your own email (skip this if you already
   have a user, e.g. because you tested the client portal with your own account).
2. Copy that user's **id** from the Users table.
3. **SQL Editor**, run (with your real id and name):

```sql
insert into profiles (id, full_name, is_admin)
values ('<your-auth-user-id>', 'Your Name', true)
on conflict (id) do update set is_admin = true;
```

## 3. Open it

Deploy the site, then visit `/admin` (or `admin.html` directly). Sign in with the email and
password from step 2. Anyone without `is_admin = true` is refused, even with a valid login.

---

## What you can do from the admin console

- **Clients** — add a client, edit its business details (name, sector, primary contact, contact email/phone — the same fields the client can edit themselves from their own Profile tab) or delete one, and open any client to manage:
  - **Bids** — add a bid, move it through the six milestones, remove it. The client's
    tracker updates the moment they reload their portal.
  - **Tasks** and **Compliance** — add items, tick/untick them yourself if needed (clients
    can also tick their own).
  - **Quotes** — add a quote, mark it accepted.
  - **Invoices** — add one, set its status.
  - **Documents** — log a document you received by email, or remove one. Anything a client
    uploads through their portal already appears here automatically.
  - **Portal access** — see whether a client has a portal login yet. Linking a new one still
    takes one manual step (below) — the public anon key the site runs on can't send invite
    emails on its own.
- **Messages** — pick a client and thread (general, or a specific bid), read what they've
  sent, and reply. Replies appear in their portal immediately.

## Linking a new client's portal login

The admin console can't send the invite email itself (that needs a privileged server key,
which never belongs in a page anyone can view-source). So, per client:

1. **Authentication → Users → Invite user**, their email.
2. Copy the new user's id.
3. In the admin console, open that client → **Portal access**, paste the id and their name,
   **Link portal user**.

Everything else — the actual bid, document, quote and message data — is fully driven from
the admin console now; you don't need the Supabase dashboard for day-to-day work anymore.

## One thing this doesn't change

`Marhana Portal Admin.dc.html` (the original mockup) is untouched and still has no backend
— it was the visual spec, and it's kept as reference per `ENGINEER-HANDOFF.md`. `admin.html`
is the real, working console; use that one from now on.
