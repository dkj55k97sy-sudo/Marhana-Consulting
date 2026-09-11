# Build brief — Portal v2: Clients, Bids, Messages

Hand this whole file to Claude Code inside the `marhana code/` repo.

Design reference: `Marhana Portal Admin.dc.html` (this project). Open it in a browser
to see the intended layout, spacing, colours and interaction for every screen described
below. Match it closely — it is the spec, not a suggestion.

**Prerequisite:** run `SUPABASE-PORTAL-V2.sql` in the Supabase SQL editor first, then
make yourself admin with the commented statement at the bottom of that file.

---

## Non-negotiables

1. **Real data only.** Every number, row, card and thread comes from Supabase. No seed
   arrays, no fallback demo objects, no "example" clients. An empty database must render
   empty states, not invented content. Delete any placeholder data you find.
2. **Admin routes are admin-only.** Everything under `/admin` requires
   `profiles.role = 'admin'`. Check server-side in a layout, not just in the UI.
3. **Works on a phone.** Below 900px the sidebar becomes a horizontal scrolling nav strip;
   tables reflow to stacked rows; the message list and thread stack vertically. Tap targets
   at least 44px.
4. **Every write is audited.** The SQL triggers handle this automatically — do not bypass
   them with service-role calls that skip `auth.uid()`.
5. **No optimistic lies.** A toast says "Saved" only after the write returns without error.

---

## Theme (already in the reference file)

| Token | Value |
|---|---|
| Page background | `#F5F1E8` |
| Card surface | `#FFFFFF`, border `#E9E1D0`, radius `14px` |
| Inset surface | `#FBF8F1`, border `#EFE8D8`, radius `12px` |
| Deep teal (sidebar, primary button) | `#0C2C2A` / `#113C39` |
| Mid teal (links, secondary) | `#2E6A60` |
| Muted text | `#8A8375`, body text `#1E2422`, secondary `#5C6360` |
| Amber (warning) | `#C4943C` / text `#8A6A22` |
| Rust (error, overdue) | `#9A4E36` |
| Headings | Cormorant Garamond 500 |
| Body / UI | Libre Franklin 300–600 |
| Uppercase labels | 10.5–11px, letter-spacing 0.14em |

Buttons: solid `#113C39` for the primary action, 1px `#D9D1BF` outline for everything else.
Pills: `border-radius: 100px`, 10–10.5px uppercase.

---

## Screen 1 — `/admin/clients`

Reads `admin_client_overview`.

**Header:** eyebrow "Accounts", h1 "Clients", one-line summary, then `Export CSV` and
`Add client`.

**Stat strip (4 cards):** active clients · awaiting invite · open bids · average document
completion %.

**Controls:** search box (name, sector, contact) and filter pills — Active ·
Needs attention · Archived · All. "Needs attention" = documents incomplete OR no portal
user yet.

**Table rows:** client name + "sector · contact"; documents `n of 12 approved` with a
progress bar (teal at 12/12, amber 9–11, rust below 9); open bids count; last activity date;
an "Archived" pill where relevant. Clicking a row expands it in place.

**Expanded panel — three things, all wired:**

- *Client details* — name, sector, primary contact, contact email. `Save changes` updates
  `clients` and shows a toast. `Archive client` / `Restore client` toggles
  `clients.archived` and sets `archived_at`.
- *Portal access* — shows whether a portal user exists. Email field + `Send invite` calls
  a server route that runs
  `supabase.auth.admin.inviteUserByEmail(email, { redirectTo: '<site>/portal' })`,
  inserts the `client_invites` row, and creates the `profiles` row with `client_id` and
  `role = 'client'` on acceptance (do this in the auth callback — the invite arrives before
  the profile exists).
- *Internal notes* — list from `client_notes` newest first with author and date, textarea +
  `Add note`. Admin-only: there is deliberately no client RLS policy on this table. Never
  surface these in the client portal.

Plus three jump buttons: Documents, Messages, Bids — each filtered to that client.

**Add client form** (toggles open under the header): organisation, sector, primary contact,
email for invite. Creates the `clients` row; if an email is given, sends the invite in the
same action.

**CSV export:** client, sector, contact, email, docs approved, required, open bids, portal
access, status, last activity. Export what the current filter shows if a filter is active;
otherwise everything.

---

## Screen 2 — `/admin/bids`

Reads `admin_bid_pipeline`. Stages come from `bid_stages`, in `position` order:

`Opportunity → Qualifying → Drafting → Internal review → Submitted → Outcome`

**Board is the default view** (a `Board / List` toggle sits in the header and persists in
`localStorage`).

**Board:** six columns, horizontally scrollable, each 268px wide. Column header shows the
stage name, the card count and the combined value. Cards show client name, bid title, buyer,
a deadline pill and the value; the card's left border carries the deadline colour — rust
when overdue, amber within the warning window (default 14 days), teal otherwise, grey once
closed. Each card has `‹` (back a stage) and `Advance` buttons that update `bids.stage`
immediately and toast the new stage. Clicking the title opens that bid's message thread.

Nice-to-have if it comes cheap: drag a card between columns. The buttons must work
regardless — do not ship drag as the only way to move a bid.

**List:** the same set as a table sorted by deadline — bid title, client · buyer, stage pill,
deadline, value, and an `Advance` action.

**Filters:** search (title, buyer, client) and pills — All open · Due soon · Closed ·
Everything.

**New bid form:** client (dropdown of active clients), title, buyer, deadline (date),
value. Lands in Opportunity at stage 0. Write `deadline_date` and `value_pence` (value in
pounds × 100), not the legacy text columns.

When a bid moves to Outcome, ask for `outcome` (Won / Lost / Withdrawn) and stamp
`outcome_at`.

**CSV export:** bid, client, buyer, stage, deadline, value, outcome.

---

## Screen 3 — `/admin/messages`

Reads `message_threads`; messages from `messages`.

**Thread model:** one thread per bid, plus one general thread per client. A thread is
`(client_id, bid_id)`; `bid_id = null` is the general thread. Do not invent a threads table
— the view already groups them.

**Left pane (max 380px):** search, filter pills (All · Unread · Bid threads), then thread
rows — client name (bold when unread), thread label ("General" or the bid title) in teal,
a one-line snippet prefixed "You: " when we sent it, a relative timestamp, and an unread
count badge. The selected thread gets a `#FBF8F1` background and a 3px `#113C39` left edge.

**Right pane:** header with client name, "label · contact", `View bid` (bid threads only)
and `Mark read / Mark unread`. Then the conversation on a `#FDFBF6` field: our messages
right-aligned in solid `#113C39` with cream text, client messages left-aligned white with
an `#EFE8D8` border. Each bubble carries "Author · 22 Aug 14:20" underneath. Composer at
the bottom: textarea plus `Send`, and ⌘↵ / Ctrl↵ sends.

**Reading:** opening a thread calls `mark_thread_read(client_id, bid_id)`. `Mark all read`
in the header clears every unread client message.

**Sending:** insert into `messages` with `from_client = false`, `author_id = auth.uid()`,
`author` = your name. The client sees it in their portal immediately.

**Notification — portal badge plus email to you:**

- The badge is `sum(unread_for_admin)` from `message_threads`, shown on the Messages nav
  item. Subscribe with Supabase Realtime on `messages` so it updates without a refresh.
- When a client sends a message, email you. Do it in a Postgres trigger calling a Supabase
  Edge Function (or a webhook to a Next.js route) that sends via Resend. Subject:
  `New message from {client} — {thread label}`. Body: the message, the sender, and a deep
  link to `/admin/messages?client={id}&bid={id}`. Fire only for `from_client = true`.
  Put the API key in Supabase secrets, never in the repo.
- Nothing emails the client on our reply — they see it in the portal. (Say the word and
  that becomes one more trigger.)

---

## Client-side views (same data, client's own rows)

The client portal already reads with RLS, so these are mostly presentation:

- **`/portal/bids`** — read-only pipeline: each bid as a row with a six-step stage tracker,
  deadline and value. No stage controls.
- **`/portal/messages`** — the same two-pane thread UI as admin, restricted to their client
  by RLS. Sending inserts with `from_client = true`; the composer is identical.
- **`/portal/documents`** — as already specified in `DOCUMENTS-BUILD-BRIEF.md`: upload,
  status, and any rejection note from us.

Never render internal notes, the audit log, or other clients' anything in the portal.
Verify by signing in as a client and confirming the queries return only their rows.

---

## Launch checklist

- [ ] `SUPABASE-PORTAL-V2.sql` run; `bid_stages` returns six rows; your profile is admin.
- [ ] Non-admin hitting `/admin/*` is redirected to `/portal`.
- [ ] Every screen renders correctly with an empty database (empty states, no crashes).
- [ ] Client A signed in cannot see Client B's bids, documents, messages or notes.
- [ ] Invite email arrives, sets a password, lands in the portal, and the `profiles` row
      gets the right `client_id`.
- [ ] Client reply produces both the nav badge and the email to you.
- [ ] Stage moves, saves, archives and notes all appear in `audit_log` with your email.
- [ ] Both CSV exports open cleanly in Excel (quoted commas, UTF-8 BOM).
- [ ] Tested at 390px wide: nav strip, stacked tables, usable composer.
- [ ] `npm run build` clean, no TypeScript errors, then `vercel deploy --prod`.
