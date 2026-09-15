# Marhana & Co — engineer handoff

**Purpose of this document.** Everything that exists, everything that doesn't, and the
decisions someone needs to make to take this live on our own domain with our own backend.
Give this whole file to the engineer. It is written so he can quote the work without a
meeting first.

Prepared: 23 August 2026.

---

## 1. What this is

Marhana & Co is a bid and tender consultancy. Clients are companies who hire us to write
and manage their public-sector tender submissions. The product has three parts:

1. **Public website** — marketing pages, already designed and built.
2. **Admin console** — internal, used by Marhana staff. Manage clients, review their
   compliance documents, track bids through a pipeline, message clients.
3. **Client portal** — external, one login per client company. They upload their documents,
   watch their bid progress, and message us.

Both consoles are designed and interactive. Neither has a backend. That is the job.

---

## 2. What exists today

| Item | State |
|---|---|
| Public website | Built and live |
| Admin console — 4 screens | Designed, fully interactive front end, **no persistence** |
| Client portal — 4 screens | Designed, fully interactive front end, **no persistence** |
| Data model | Specified in this document (section 6) |
| Backend | Does not exist |
| Auth | Does not exist |
| File storage | Does not exist |
| Email sending | Does not exist |

### The two console files

- `Marhana Portal Admin.dc.html` — internal console. Overview, Clients, Bids, Documents.
- `Marhana Client Portal.dc.html` — client-facing. Overview, Documents, Bids, Messages.

These are self-contained HTML files. Open either in a browser and every button works —
you can add a client, move a bid through the pipeline, approve a document, send a message.
**All of it is held in browser memory and lost on refresh.** They are a precise, working
specification of the intended behaviour, not a prototype to be thrown away. The layout,
copy, states, empty states and interactions are all decided; they should be preserved.

### Earlier work that exists but is superseded

There was an earlier attempt using Supabase as the backend. Those artefacts are still in
the project and may be useful as reference for the data model, but the intention now is a
backend we own:

- `SUPABASE-PORTAL-V2.sql` — schema, permissions, audit triggers, views. **Read this.**
  Even if we don't use Supabase, it is the fullest existing statement of the data model
  and the access rules, and translates directly to plain PostgreSQL.
- `SUPABASE-DOCUMENTS-MIGRATION.sql`, `supabase-schema.sql` — earlier iterations.
- `PORTAL-V2-BUILD-BRIEF.md`, `DOCUMENTS-BUILD-BRIEF.md` — screen-by-screen behaviour
  specs written for the Supabase version. The behaviour descriptions are still correct;
  ignore the Supabase-specific instructions.

---

## 3. What we want (the ask, in one paragraph)

Our own domain, our own database, our own backend. No dependency on a hosted
backend-as-a-service. The two console designs wired to real data so that when a client
uploads a document it actually arrives, we review it, and they see the outcome. Secure
enough that Client A can never see Client B's anything. Live and usable by us day to day.

---

## 4. Decisions the engineer should make (with recommendations)

These are his call — the recommendations are only so he knows what we're comfortable with.

**Domain.** We buy it (see section 11). He tells us what DNS records to add.

**Hosting.** Anything he can operate confidently: a VPS (Hetzner, DigitalOcean), a managed
platform (Railway, Render, Fly), or AWS. We want predictable monthly cost, HTTPS, automatic
certificate renewal, and nightly database backups that are actually restorable.

**Backend stack.** His choice entirely. Node/Express, Node/Nest, Go, Python/FastAPI,
Laravel — whatever he maintains fastest. The only hard requirement is a **relational
database**; PostgreSQL preferred, MySQL acceptable. The data is relational and the access
rules depend on it. Please not a document store.

**Frontend integration.** Two reasonable routes, his preference:
- **A.** Serve the existing HTML consoles as-is and have them fetch a JSON API. Fastest
  path; the designs are already complete.
- **B.** Port the screens into a framework (Next.js, Remix, Nuxt) and render server-side.
  More work, better long-term, better SEO for the public site (though the consoles are
  behind a login so SEO is irrelevant there).

Either is fine. If he picks B, the HTML files remain the visual and behavioural spec and
should be matched closely rather than reinterpreted.

**File storage.** Documents are commercially sensitive (insurance certificates, accounts,
staff records). They must not be publicly reachable by URL. Either S3-compatible object
storage with time-limited signed URLs, or disk on the server with downloads streamed
through an authenticated endpoint. Not a public folder.

**Email.** Transactional only. Postmark, Resend, SES, or plain SMTP. Two things need to
send: portal invitations and a notification to us when a client messages or uploads.

---

## 5. Business rules he needs to know

These are the rules the screens already implement. They're the part that isn't obvious
from a schema.

**Every client has the same twelve required documents:**

1. Insurance certificates
2. Health & safety policy
3. Accreditations (CHAS, SafeContractor)
4. Company accounts
5. Method statements
6. Risk assessments
7. Case studies / past projects
8. Staff CVs
9. Signed contracts
10. Completed bid submissions
11. ID / right to work
12. Quality certifications (ISO)

The list is currently fixed. It should live in a database table, not in code, because we
will want to change it without a deployment.

**Document lifecycle.** A document row exists for all twelve from the moment a client is
created, starting as *missing*. The client uploads → *pending*. We approve → *approved*,
or reject with a written reason → *rejected*, and the client sees that reason and uploads a
replacement. Some documents carry an expiry date.

**Two statuses are derived, not stored:** *expiring* (approved, expiry date within the
warning window — default 14 days, configurable) and *expired* (approved, expiry date past).
Store `status` and `expiry_date`; compute the rest. Do not write "expiring" into the
database — it would silently go stale.

**Bid pipeline, six stages in order:** Opportunity → Qualifying → Drafting →
Internal review → Submitted → Outcome. Only stage 5 (Outcome) is terminal, and it carries
an outcome of Won, Lost or Withdrawn plus the date. Stages must be a database table, in
order, because we will rename them.

**Messaging threads.** A thread is a client plus an optional bid: one thread per bid, plus
one general thread per client. There is no threads table — a thread is just the messages
sharing that pair. Unread is per side: unread-for-us means the client wrote and we haven't
read it, and vice versa.

**Internal notes** on a client are staff-only and must never be exposed to any client
endpoint, ever. Same for the audit log.

**Audit trail.** Every create, update and delete on clients, bids, documents, messages,
notes and invites records who did it, when, and the before/after values. Database triggers
are the safest place for this — application-level logging gets forgotten.

**Client activity.** Each client shows a last-activity date, touched by any message or
document change on their account.

---

## 6. Data model

Written as PostgreSQL. `SUPABASE-PORTAL-V2.sql` contains a working version of most of this
including the views and triggers — worth reading before writing it fresh.

**clients** — id, name, sector, contact_name, contact_email, contact_phone, archived
(bool), archived_at, last_activity_at, created_at

**users** — id, email, password_hash, name, role (`admin` | `client`), client_id (null for
admins), last_login_at, created_at. One client company may have several portal users.

**document_types** — id, position (for display order), name, required (bool),
expires (bool — whether an expiry date is expected)

**documents** — id, client_id, document_type_id, status (`missing` | `pending` |
`approved` | `rejected`), file_path, file_name, file_size, mime_type, uploaded_at,
uploaded_by, expiry_date, review_note (the rejection reason shown to the client),
reviewed_at, reviewed_by. Unique on (client_id, document_type_id) — one current row per
required document. Keep superseded versions in a `document_versions` table if he wants
history; we'd like it but it isn't v1-critical.

**bid_stages** — position (0–5), name, is_closed

**bids** — id, client_id, title, buyer, deadline_date, value_pence (integer pence, not a
float), stage (0–5, constrained), outcome, outcome_at, owner_id, created_at, updated_at

**messages** — id, client_id, bid_id (nullable — null is the general thread), body,
from_client (bool), author_id, author_name, attachment_path, read_at, created_at

**client_notes** — id, client_id, body, author_id, author_name, created_at *(staff only)*

**client_invites** — id, client_id, email, token, invited_by, invited_at, accepted_at,
status (`sent` | `accepted` | `revoked` | `expired`)

**audit_log** — id, at, actor_id, actor_email, action, table_name, row_id, client_id,
summary, before (jsonb), after (jsonb)

Two read views make the dashboards cheap: one row per client with document completion,
open bid count and unread messages; and one row per thread with the last message, its
sender and both unread counts. Both are in the SQL file.

---

## 7. API surface

Roughly what the screens need. Names and shapes are his call.

**Auth** — log in, log out, current user, request password reset, set password from an
invite token. Sessions in httpOnly cookies preferred over tokens in localStorage.

**Admin — clients:** list (with the overview aggregates), create, update, archive/restore,
list/add internal notes, send invite, export CSV of the current filter.

**Admin — bids:** list (with stage names and days-to-deadline), create, update, change
stage, record outcome, export CSV.

**Admin — documents:** all clients with completion figures; one client's twelve documents;
approve; reject with a note; mark received on our behalf (we sometimes get documents by
email and log them ourselves); download a file via a signed or authenticated URL.

**Admin — messages:** thread list with unread counts, one thread's messages, send, mark
thread read, mark all read.

**Client — everything scoped to their own client_id, enforced server-side:** their twelve
documents; upload a file; set an expiry date; their bids read-only; their threads; send a
message; mark read. There is no client endpoint that takes a client_id as a parameter —
it always comes from the session.

---

## 8. Security requirements

Non-negotiable, in rough order of importance:

1. **Client isolation.** Every client-facing query is filtered by the session's client_id
   server-side. Never trust an id from the request body or URL. This should be tested
   deliberately: log in as Client A and try to fetch Client B's document by id.
2. **Admin routes require role = admin**, checked on the server for every request, not
   just hidden in the UI.
3. **Documents are never publicly reachable.** Signed URLs with short expiry, or streamed
   through an authenticated endpoint. No guessable paths, no public bucket.
4. **Uploads validated** — allowed types (PDF, common image formats, Office documents),
   size cap (say 25 MB), and the stored filename generated rather than taken from the user.
   Virus scanning is a bonus, not a blocker.
5. **HTTPS everywhere**, HSTS, secure cookies, CSRF protection on state-changing requests.
6. **Rate limit** login and password reset.
7. **Secrets in environment variables**, never in the repository. Rotate anything that has
   ever been committed.
8. **GDPR basics.** This holds staff CVs and right-to-work documents, which is personal
   data. We need to be able to export and delete a client's data on request, and we should
   agree a retention period for superseded documents.

---

## 9. Notifications

- **Client sends a message** → email to us, subject `New message from {client} — {thread}`,
  with the message body and a deep link into the admin console. Plus an unread badge on the
  Messages tab.
- **Client uploads a document** → email to us, or a single daily digest if we get noisy.
- **We reject a document** → the client sees the reason in their portal. Whether that also
  emails them is a decision we haven't made; build it so it can be switched on.
- **Bid deadline approaching** → a daily digest to us of anything due inside the warning
  window would be genuinely useful. Nice-to-have.
- **Invite** → the one email that must work perfectly. Link sets a password and lands the
  user in their portal with the right client attached.

Live updating: badges and statuses should update without a manual refresh. Websockets are
ideal; polling every 30–60 seconds is perfectly acceptable for our volume.

---

## 10. Environments

- **Local** — his machine, seeded with fake data.
- **Staging** — a subdomain such as `staging.ourdomain.com`, real deployment, fake data,
  search-engine blocked. This is where we sign work off.
- **Production** — the real domain, real clients. Nightly database backups with a restore
  actually tested once. Error tracking (Sentry or similar) and uptime monitoring.

Deployments from a git repository we own. We'd like access to that repository even though
we won't be writing code — it's our asset.

---

## 11. Domain and DNS

We buy the domain in our own name, with our own registrar account, and keep the login.
Cloudflare, Namecheap and Porkbun are all fine. He should never need to own it.

We'll want:
- `ourdomain.com` — public website
- `ourdomain.com/portal` — client portal (or `portal.ourdomain.com`, his preference)
- `ourdomain.com/admin` — admin console
- Email on the domain (`hello@`, `aman@`) — Google Workspace or Fastmail
- SPF, DKIM and DMARC records set up properly, otherwise our invite emails go to spam

He tells us the records to add; we add them, or grant him access to do it.

---

## 12. Acceptance checklist

The definition of finished. We will walk through this together before going live.

- [ ] Admin can create a client; their twelve document rows appear automatically
- [ ] Invite email arrives, sets a password, and lands in the correct client's portal
- [ ] Client uploads a document; it appears in our review queue as *pending*
- [ ] We approve it; the client sees *approved* without a manual refresh
- [ ] We reject it with a reason; the client sees the reason and can upload a replacement
- [ ] Expiry dates produce *expiring* and *expired* correctly, driven by the real date
- [ ] Admin can create a bid and move it through all six stages; the client sees the stage
      change but has no controls
- [ ] Recording an outcome (Won/Lost/Withdrawn) closes the bid
- [ ] Messages work both ways, in the general thread and per-bid threads; unread counts are
      correct on both sides
- [ ] Client message triggers the email to us
- [ ] **Client A cannot reach any of Client B's data** — tested by direct API calls, not
      just by clicking around
- [ ] Internal notes and the audit log are invisible to every client endpoint
- [ ] A non-admin hitting an admin URL is refused server-side
- [ ] Every action appears in the audit log with the actor's email
- [ ] Both CSV exports open cleanly in Excel
- [ ] Usable on a phone at 390px wide
- [ ] Empty database renders empty states, never a crash and never placeholder content
- [ ] Backups run nightly and a restore has been tested once
- [ ] HTTPS, secure cookies, no secrets in the repository

---

## 13. Deliberately out of scope for v1

Worth saying so nobody quotes for them: invoicing and payments, e-signatures, a document
preview/viewer inside the app, multi-language, a public client-facing dashboard, SSO,
mobile apps, and any AI features. Some of these we may want later; none of them now.

---

## 14. Questions for him

1. What stack would you build this in, and how long for the acceptance list in section 12?
2. Where would you host it, and what's the realistic monthly running cost — hosting,
   database, storage, email, monitoring?
3. Do you want to serve our existing HTML consoles against a JSON API, or port the screens
   into a framework? What does each cost us in time?
4. How do you want to handle file storage, and how do you keep documents unreachable
   without a session?
5. What do you need from us to start — domain, DNS access, the design files, anything else?
6. Who maintains it after launch, and on what terms? What happens when something breaks at
   9pm on a Friday?
7. Will the repository and infrastructure be in accounts we own?
8. Is any of the existing SQL (`SUPABASE-PORTAL-V2.sql`) reusable, or would you start the
   schema fresh?

---

## 15. What we can hand over immediately

- `Marhana Portal Admin.dc.html` — the admin console, working front end
- `Marhana Client Portal.dc.html` — the client portal, working front end
- `SUPABASE-PORTAL-V2.sql` — data model, views, audit triggers, access rules
- `PORTAL-V2-BUILD-BRIEF.md` — screen-by-screen behaviour, colours, type, states
- `DOCUMENTS-BUILD-BRIEF.md` — the document review flow in detail
- This document
- The public website source, and the logo and brand assets
