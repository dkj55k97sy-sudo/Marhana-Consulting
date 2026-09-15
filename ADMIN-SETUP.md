# Making the admin console real

Short answer to "is the admin portal linked to the client portal": **it wasn't** — `Marhana
Portal Admin.dc.html` was a design mockup with no backend at all (see
`ENGINEER-HANDOFF.md`, section 2: "no persistence"). Nothing you clicked there was ever
saved anywhere, and it had no connection to the client portal or its data.

`admin.html` is the real, working console, built to match that design exactly — same
screens, same layout, same copy — wired to the **same** Supabase database the live client
portal (`portal.html`) already uses. They are now genuinely connected: approve a document,
move a bid, or reply to a message as admin, and the client sees it the moment they reload
their portal. Nothing needs syncing because there's only one database.

---

## 1. Run two SQL files, in order

In the Supabase project you already have connected (`supabase.com` → your `marhana-portal`
project → **SQL Editor** → **New query**), run each of these as its own query, in this order:

1. `SUPABASE-ADMIN-ACCESS.sql` — if you haven't already. Adds the `is_admin` flag and the
   database rules that let a flagged admin read and write every client's data, without
   weakening how locked-down client access already is.
2. `SUPABASE-ADMIN-V2.sql` — adds what the full console needs: client archiving, a real
   numeric bid value, the twelve-required-document approval workflow (with a database
   trigger that gives every client those twelve rows automatically, including a one-time
   backfill for clients you already created), and staff-only internal notes.

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

## What's on each screen

- **Overview** — six KPIs (unread messages, awaiting review, expired documents, bids due
  soon, active clients, live pipeline value), a "Needs you today" list pulling together
  overdue/upcoming bids, unread threads and document issues — each with a jump-to link —
  plus a pipeline breakdown and a recent-activity feed.
- **Clients** — stats, search, filter pills (Active / Needs attention / Archived / All),
  CSV export, and an "Add client" form. Opening a client gives you their editable details,
  portal access, internal notes (staff-only — never exposed to any client endpoint), and
  quick links into their Documents, Messages and Bids.
- **Bids** — a kanban board (or list view) across every client, six stages —
  **Opportunity → Qualifying → Drafting → Internal review → Submitted → Outcome**. New bid
  form, search, filters, CSV export, Advance/Back on every card.

  Note: this is deliberately different wording from the client portal's own bid tracker
  (Kick-off → Storyboarding → Drafting → Quality Assurance → Client Sign-off → Submission).
  Both read and write the same underlying stage number (0–5) — only the label differs
  between what staff see here and what clients see in their portal.
- **Messages** — two-pane threads (general, or per-bid) across every client, unread counts
  on the nav item and per-thread, search, filters, "Mark all read", start a new thread.
- **Documents** — the twelve required documents, tracked per client: Approve, Reject (with
  a note), Mark received, Chase, View. A "Needs your attention" queue across all clients,
  soonest-expiring first, and an all-clients compliance table. *Expiring*/*expired* are
  computed from the expiry date you set on approval — never stored, so they can't go stale.

  This is separate from the client portal's own free-form Document Vault (where clients
  upload whatever they like into folders) — that keeps working exactly as before and isn't
  shown here; this screen is specifically the twelve-item compliance checklist.

## Linking a new client's portal login

The console's "Send invite" button saves the email to the client's record, but it can't
actually send the invite or finish the link itself — that needs a privileged server key,
which never belongs in a page anyone can view-source. So, per client:

1. **Authentication → Users → Invite user**, their email.
2. Copy the new user's id.
3. **SQL Editor**, run (with their real id, name and client id — the client id is in the
   URL when you open that client's Supabase `clients` table row, or `select id from clients
   where name = '...'`):

```sql
insert into profiles (id, client_id, full_name)
values ('<their-auth-user-id>', '<their-client-id>', 'Their Name');
```

Everything else — bids, the document checklist, notes, messages — is fully driven from the
admin console now; you don't need the Supabase dashboard for day-to-day work otherwise.

## One thing this doesn't change

`Marhana Portal Admin.dc.html` (the original mockup) is untouched and still has no backend
— it was, and remains, the visual spec. `admin.html` now matches it and is the real,
working console; use that one from now on.
