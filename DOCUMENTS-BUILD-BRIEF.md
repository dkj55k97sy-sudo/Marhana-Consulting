# Build brief — Admin Documents page

Give this file to Claude Code inside the portal folder. The visual reference is
`Marhana Portal Documents.dc.html`; match its layout, spacing and copy. Do not
restyle it.

## Before you start

Run `SUPABASE-DOCUMENTS-MIGRATION.sql` in Supabase → SQL Editor, then make
yourself an admin with the `update profiles set is_admin = true` statement at the
bottom of that file. Nothing below works until that is done.

## What exists in the database

- `document_types` — the twelve required documents, with `sort`,
  `requires_expiry` and `guidance`.
- `documents` — extended with `doc_type_id`, `status`
  (`pending` / `approved` / `rejected`), `expiry_date`, `review_note`,
  `reviewed_at`, `reviewed_by`, `uploaded_by`, `mime_type`, `size_bytes`.
- `client_document_status` — a view giving one row per client per required
  document, with a derived `status` of `missing` / `pending` / `rejected` /
  `expired` / `approved`, plus `days_until_expiry`. Read the page from this view.
  Never recompute status in the app.
- `is_admin()` — true for admin profiles. RLS gives admins full reach; clients
  still see only their own rows.
- Storage bucket `client-documents`, private.

## Pages to build

### `/admin/documents` — the overview

Guard the route: read the current user's profile, and if `is_admin` is false,
redirect to `/portal`.

One query does most of it:

```ts
const { data } = await supabase
  .from('client_document_status')
  .select('*')
  .order('client_name')
```

From that array, derive in the component:

- Five counters: awaiting review (`status = 'pending'`), expired, expiring
  (`status = 'approved'` and `days_until_expiry <= 45`), not supplied
  (`missing` + `rejected`), and fully compliant clients (all twelve `approved`).
- The **Needs your attention** queue: every row whose status is not `approved`,
  plus approved rows inside the expiry window, sorted by `days_until_expiry`
  ascending with nulls last. Show all of them, not a slice.
- The **All clients** table: group rows by `client_id`, count approved for the
  progress bar, and show the worst outstanding item as the earliest issue.
  Wire the search box and the All / Needs review / At risk / Complete filters.

Keep the two totals in the subhead and the queue header reading from the same
array so they cannot disagree.

### `/admin/documents/[clientId]` — one client

Query the same view filtered to `client_id`, ordered by `doc_sort`, then sort by
status severity for display (expired, pending, expiring, missing, approved).

Actions per row, matching the mockup:

- **Approve** — `update documents set status = 'approved', reviewed_at = now(),
  reviewed_by = auth.uid() where id = document_id`.
- **Reject** — same, `status = 'rejected'`, plus the note from the textarea into
  `review_note`. Then insert a row into `messages` for that client so they see
  why, with `from_client = false`.
- **Chase / Request** — insert a `messages` row naming the document. Do not
  invent an email integration; the portal message is the notification.
- **View** — `supabase.storage.from('client-documents').createSignedUrl(storage_path, 60)`
  and open the returned URL. Never build a public URL; the bucket is private.
- **Upload on their behalf** — file input, upload to
  `client-documents/{clientId}/{docTypeId}/{timestamp}-{filename}`, then insert a
  `documents` row with that `storage_path`, the `doc_type_id`, `size_bytes`,
  `mime_type`, and `status = 'approved'` since you are the one supplying it.
  Ask for an expiry date first when the type's `requires_expiry` is true.

After any write, re-fetch the view rather than patching local state, so the
counters stay honest.

## Rules

- No mock data, no seeded example clients. An empty database must render an empty
  page with a plain line of copy, not placeholders.
- Every write goes through the authenticated Supabase client so RLS applies.
  Never use the service role key in the app.
- Dates are real: format `expiry_date` and derive "in N days" from
  `days_until_expiry`. Do not hardcode today's date.
- Colours and type come from the mockup: background `#F5F1E8`, sidebar `#0C2C2A`,
  primary `#113C39`, mid `#2E6A60`, muted `#8A8375`, card border `#E9E1D0`,
  amber `#8A6A22`, red `#9A4E36`. Cormorant Garamond for headings, Libre Franklin
  for body.

## Then, the client side

The same view drives the client's own Documents page — filtered to their
`client_id` by RLS automatically, so the query needs no `where` clause. They see
the twelve rows, which ones you are waiting on, any rejection note, and an upload
control per row. Build that after the admin side works.
