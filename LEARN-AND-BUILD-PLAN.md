# Marhana Portal — Learn & Build Plan

**What this is.** A twelve-week plan to take you from no backend experience to the
Marhana admin console and client portal running live on your own domain, with real logins,
real file uploads and real data.

**Why this plan is shorter than a normal "learn to code" path.** Two of the three hard
jobs are already finished. The screens are designed and interactive. The data model is
written (`SUPABASE-PORTAL-V2.sql`). What's missing is the wiring, and that is the part
you're going to learn. You are not learning to be a software engineer. You are learning
exactly enough to connect finished screens to a real database, and no more.

**Time commitment.** 8–10 hours a week. Two hours on four weeknights, or a couple of longer
weekend sessions. Consistency beats intensity — the concepts stack, and gaps mean
re-learning.

**The stack you're learning, and why.**

| Piece | What we use | Why this and not something else |
|---|---|---|
| Database + auth + file storage | Supabase | It hands you PostgreSQL, logins, file storage and permission rules through a dashboard. Doing these three yourself is where months go. |
| App framework | Next.js | Serves your pages and your API in one project, deploys to Vercel in one command. |
| Hosting | Vercel | Free tier covers you, connects to a custom domain, deploys from git. |
| Language | JavaScript | Already what your screens are written in. |

**A promise about the destination.** At the end you will not have a toy. You will have the
system in your acceptance checklist (`ENGINEER-HANDOFF.md` section 12): you add a client,
they get an invite email, they log in, they upload their insurance certificate, you approve
or reject it with a reason, they see the outcome, and neither client can see the other's
anything.

---

## How to use this document

Each week has four parts:

- **Learn** — the material, with links. Free, all of it.
- **Why** — what this unlocks in your own project. Read this when motivation dips.
- **Build** — what must exist in your project by Sunday night.
- **Done when** — a test you can run. If it fails, don't move on. A shaky week 4 makes
  week 7 impossible.

Two rules that will save you weeks:

1. **Type the code, don't paste it.** Tutorial code you paste teaches you nothing. Code you
   type badly and then fix teaches you everything.
2. **When stuck for more than 40 minutes, ask.** Paste the error into Claude or ChatGPT with
   what you expected to happen. Being stuck for three hours is not virtue, it's lost time.

---

# PHASE ONE — Foundations (weeks 1–3)

You cannot wire screens to a database without being able to read the code in front of you.
Three weeks buys you that. It is the least glamorous part of this plan and the part most
people skip, and skipping it is why they stall in week 6.

---

## Week 1 — JavaScript that you can read

### Learn

**Primary (about 8 hours):**
[freeCodeCamp — JavaScript Algorithms and Data Structures](https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures/)
Do the **Basic JavaScript** section end to end. Skip the algorithm challenges at the end —
you will not be writing sorting algorithms.

**Focus hard on these, they are what your project is made of:**

- Variables: `const`, `let`
- Objects and arrays, and reading nested values (`client.contact_email`)
- Functions, including arrow functions (`() => { }`)
- `if` / `else`, and the ternary (`x ? a : b`)
- Array methods: `.map()`, `.filter()`, `.find()`, `.length`
- Template strings with backticks
- `async` / `await` — you will not fully understand this yet. That is expected and fine.

**Reference when confused:** [javascript.info](https://javascript.info) — better written than
MDN for a beginner. Chapters 2 and 4–5.

### Why

Open `Marhana Portal Admin.dc.html` and search for `renderVals`. Everything in there is
`.map()`, `.filter()` and objects. Right now it looks like noise. By Friday it will look
like sentences. Nothing else this week matters as much as that shift.

### Build

Nothing in the project yet. Instead:

1. Install [VS Code](https://code.visualstudio.com) (free).
2. Install [Node.js](https://nodejs.org) — the LTS version.
3. Open `Marhana Portal Admin.dc.html` in VS Code. Find the `STAGES` array near the top.
   Change `'Qualifying'` to `'Qualification'`. Save. Open the file in your browser and find
   your change on the Bids screen. Change it back.
4. Create a free [GitHub](https://github.com) account.

### Done when

You can look at this and say out loud what it produces:

```js
const active = clients.filter(c => !c.archived);
const names = active.map(c => c.name);
```

If you can, you're ready. If not, spend another few evenings in Basic JavaScript — this
one is worth being slow about.

---

## Week 2 — SQL and how your data is shaped

### Learn

**Primary (about 4 hours):** [SQLBolt](https://sqlbolt.com) — lessons 1 through 12.
Interactive, in the browser, nothing to install. Finish it.

**Then (about 3 hours):**
[freeCodeCamp — Relational Database certification](https://www.freecodecamp.org/learn/relational-database/),
the "Learn Relational Databases" section only.

**What you must come away understanding:**

- A table is rows and columns, and one row is one thing (one client, one document)
- `SELECT ... FROM ... WHERE` — asking for specific rows
- `INSERT`, `UPDATE`, `DELETE` — creating, changing, removing
- A **primary key** — the id that uniquely identifies a row
- A **foreign key** — how `documents.client_id` points at `clients.id`
- A `JOIN` — reading from two related tables at once
- `COUNT`, and `GROUP BY` at a basic level

### Why

Now read `SUPABASE-PORTAL-V2.sql`. Actually read it, top to bottom, slowly. You will not
understand every line. You will understand `create table`, the columns, and why
`documents` has a `client_id`. That file is the skeleton of your entire business —
every client, every document status, every message. Understanding it is understanding your
own product.

### Build

Still nothing running. Instead, on paper or in a document, answer these from your own
project:

1. Which table holds the list of twelve required documents, and why is it a table rather
   than a list in the code? (`ENGINEER-HANDOFF.md` section 5 answers this.)
2. If a client has uploaded 5 of 12 documents, how many rows are in `documents` for them?
   (Careful — the answer is 12, and section 5 explains why.)
3. Write, by hand, the SQL that would list every document for one client:
   `select * from documents where client_id = '...';`

### Done when

You can explain to someone else, without notes, why `expiring` is not stored in the
database but calculated from `expiry_date`. This is the single most important design
decision in your schema and it must be yours, not mine.

---

## Week 3 — React, only the parts your screens use

### Learn

**Primary (about 6 hours):** [react.dev/learn](https://react.dev/learn) — "Quick Start",
"Describing the UI", "Adding Interactivity". Stop at "Managing State".

**Focus on exactly four ideas:**

1. **Components** — a function that returns markup
2. **Props** — values passed into a component
3. **State** — data that changes, and re-renders the screen when it does
4. **Events** — `onClick` and friends

Ignore: hooks beyond `useState`, context, refs, performance, effects. You will not need
them.

### Why

Your two console files are React underneath. When you click "Approve" on a document and the
pill changes to *Approved* and the progress ring moves — that is state changing and the
screen re-rendering. In week 8 you will make that same click also write to your database.
You need to know which part of that sentence is which.

### Build

1. Open `Marhana Client Portal.dc.html`. Find `state = {` in the logic.
2. Find the `docs:` line inside it. Every one of your twelve documents starts as
   `status: 'missing'`.
3. Change the first one to `status: 'approved'`. Save, reload the file in your browser.
   The counter, the ring and the filters all move. **That is state.**
4. Change it back.

### Done when

You can point at a specific line in your own file and say "this is state, and when it
changes the screen redraws". Not a tutorial's file. Yours.

---

# PHASE TWO — Backend foundations (weeks 4–6)

Now you build the thing your screens will talk to.

---

## Week 4 — Supabase: your database, live

### Learn

- [Supabase — Getting Started](https://supabase.com/docs/guides/getting-started) (1 hour)
- [Supabase — Database](https://supabase.com/docs/guides/database/overview) (2 hours)
- [Supabase — Tables and Data](https://supabase.com/docs/guides/database/tables) (1 hour)

### Why

This is the week your business stops living in a browser tab and starts living in a
database. From here on, data you enter is still there tomorrow.

### Build

1. Create a free Supabase account and a new project. Name it `marhana-portal`.
   **Write the database password down somewhere safe** — it is not recoverable.
2. Choose the region closest to you (London, if you're UK).
3. Open the **SQL Editor**.
4. Paste the entire contents of `SUPABASE-PORTAL-V2.sql` and run it.
5. Read the output. If it errors, read *which line* — usually a table from an earlier
   migration is missing. Run `supabase-schema.sql` first, then try again.
6. Go to **Table Editor**. You should see `clients`, `bids`, `documents`, `messages`,
   `bid_stages`, `client_notes`, `client_invites`, `audit_log`.
7. Click `bid_stages`. Six rows: Opportunity through Outcome. **This is your pipeline,
   in a real database.**
8. In `clients`, click "Insert row" and add one test client by hand — name it
   `Test Company Ltd`. Save it.
9. In the SQL Editor, run `select * from clients;` and see your row come back.

### Done when

You have added, edited and deleted a row in `clients` through both the Table Editor and a
SQL query, and `select * from bid_stages order by position;` returns your six stages in
order.

---

## Week 5 — Next.js: your application shell

### Learn

**Primary (about 8 hours):** [nextjs.org/learn](https://nextjs.org/learn) — the
"App Router" course, chapters 1 through 6. This is the best free tutorial in web
development. Do not skim it.

**What you're taking from it:**

- Creating and running a project locally
- Pages and routing (a folder becomes a URL)
- Layouts
- Server components vs client components (roughly — the detail comes later)
- Fetching data and showing it on a page

### Why

Your finished product is a Next.js app: `/` is your website, `/admin` is your console,
`/portal` is your clients'. This week you learn the container everything goes into.

### Build

1. In a terminal: `npx create-next-app@latest marhana-portal`
   Answer: TypeScript **no**, ESLint **yes**, Tailwind **no**, App Router **yes**.
2. `cd marhana-portal` then `npm run dev`. Open `localhost:3000`.
3. Create `app/admin/page.js` with a heading that says "Admin". Visit `/admin`. It works.
4. Create `app/portal/page.js` saying "Client portal". Visit `/portal`.
5. Push the project to GitHub (VS Code's Source Control panel will walk you through it).
6. Connect the repository to [Vercel](https://vercel.com) and deploy. You now have a live
   URL with two empty pages on it.

### Done when

`yourproject.vercel.app/admin` loads from the internet, and pushing a change to GitHub
updates it within a minute without you doing anything.

---

## Week 6 — Connecting Next.js to Supabase, and logging in

### Learn

- [Supabase with Next.js](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs) (2 hours)
- [Supabase Auth](https://supabase.com/docs/guides/auth) (3 hours) — read carefully
- [Server-Side Auth for Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs) (2 hours)

### Why

This is the answer to the question you asked me: *how do I log into the admin portal?*
It's this week. You create your own account, mark it admin, and `/admin` starts refusing
everyone else.

### Build

1. `npm install @supabase/supabase-js @supabase/ssr`
2. Create `.env.local` with your Supabase URL and anon key (Settings → API in Supabase).
   Confirm `.env.local` is listed in `.gitignore` — **these must never reach GitHub.**
3. Follow the server-side auth guide exactly: create the client helpers and the
   `middleware.js` it describes.
4. Build `app/login/page.js` — email and password fields, calling
   `supabase.auth.signInWithPassword()`.
5. In Supabase → **Authentication → Users**, create your own user with your real email.
6. In the SQL Editor, make yourself admin (the commented statement at the bottom of
   `SUPABASE-PORTAL-V2.sql` — uncomment it and put your email in).
7. Build `app/admin/layout.js` that reads the session server-side, looks up the profile
   role, and redirects to `/portal` if it isn't `admin`.
8. In Vercel → Settings → Environment Variables, add the same two values, and redeploy.

### Done when

Three things are true: signed out, `/admin` sends you to `/login`. Signed in as yourself,
`/admin` loads. And a second test user you create *without* the admin role gets bounced
from `/admin` to `/portal`.

**That is the answer to your login question, working, on the internet.**

---

# PHASE THREE — Wiring your real screens (weeks 7–10)

Everything up to now has been groundwork. Now your own designs come alive, one screen at a
time, easiest first.

The pattern is the same every week: read data from Supabase, pass it into the screen,
replace the in-memory state with a real database write. Once you've done Clients, the rest
are variations.

---

## Week 7 — The Clients screen (your first real one)

### Learn

- [Supabase — Querying data](https://supabase.com/docs/reference/javascript/select) (1 hour)
- [Supabase — Insert, Update, Delete](https://supabase.com/docs/reference/javascript/insert) (1 hour)
- [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security) (3 hours) — **the most important reading in this entire plan**

### Why

Clients is the right first screen: no file uploads, no threading, no stage logic. Just a
list, a form, and an editable row. And RLS is the mechanism that stops Client A seeing
Client B — it is the difference between a real product and a liability.

### Build

1. Move the Clients markup from `Marhana Portal Admin.dc.html` into
   `app/admin/clients/page.js`.
2. Read real clients: `const { data } = await supabase.from('clients').select('*')`
3. Delete the sample-data logic. Render `data` instead.
4. Wire "Add client" to a real `insert`. Add one through your own form and watch the row
   appear in the Supabase Table Editor.
5. Wire "Save changes" to `update`, and Archive to setting `archived = true`.
6. Wire internal notes to `client_notes` — insert on Add note, read the list back.
7. Confirm the admin RLS policies from your SQL file are active (Authentication → Policies).

### Done when

You add a client in your browser, refresh the page, and they're still there. You edit their
sector, refresh, it stuck. And `audit_log` in Supabase has a row for each of those actions
with your email on it.

**This is the week it becomes real software.** Sit with that for a moment.

---

## Week 8 — Documents, both sides

### Learn

- [Supabase Storage](https://supabase.com/docs/guides/storage) (3 hours)
- [Storage access control](https://supabase.com/docs/guides/storage/security/access-control) (2 hours)
- [Signed URLs](https://supabase.com/docs/guides/storage/serving/downloads) (1 hour)

### Why

The heart of your business. This is the workflow you sell: they send documents, you check
them, nothing expires unnoticed.

Take the security here seriously. These files are insurance certificates, company accounts,
staff right-to-work documents. A public bucket is a data breach.

### Build

1. Create a Storage bucket named `client-documents`. **Set it to private.**
2. Add the storage policies so a client can only write to their own folder
   (`client_id/filename`), and only admins can read everything.
3. Build `app/portal/documents/page.js` from your client portal design. Wire the upload
   button to `supabase.storage.from('client-documents').upload(...)`, then set that
   document row's status to `pending`.
4. Build `app/admin/documents/page.js`. List clients with completion counts (the
   `admin_client_overview` view already computes this — use it).
5. Wire Approve → `status = 'approved'`. Wire Reject → `status = 'rejected'` plus the
   `review_note` from your textarea.
6. Downloads: generate a signed URL, expiring in 60 seconds. Never a public link.
7. Compute `expiring` and `expired` from `expiry_date` at read time. Do not store them.

### Done when

Signed in as a test client, you upload a PDF. Signed in as yourself, you see it pending,
open it, and reject it with a reason. Back as the client, the reason is on screen and you
can upload a replacement. Then: copy the file's storage path, sign out entirely, and try to
open it. **It must refuse you.**

---

## Week 9 — Bids and the pipeline

### Learn

- Nothing new. This week is repetition of week 7's pattern, which is the point — you
  should feel it getting easier.
- Optional: [Supabase Realtime](https://supabase.com/docs/guides/realtime) (2 hours) if
  you want live updates without a refresh.

### Why

Proves the pattern generalises, and gives your clients the thing they actually ask for on
the phone: where is my bid up to.

### Build

1. `app/admin/bids/page.js` — the board from your admin design, six columns from
   `bid_stages`, cards from `bids`.
2. Advance / back buttons write the new `stage`. Read stage names from the table, never
   hardcode them.
3. Moving to Outcome asks for Won / Lost / Withdrawn and stamps `outcome_at`.
4. New bid form inserts a row. Store `value_pence` as pence in an integer — never a
   decimal for money.
5. `app/portal/bids/page.js` — the read-only tracker from your client design. **No stage
   controls.** Verify a client cannot change a stage even by calling the API directly.
6. Both CSV exports.

### Done when

You create a bid in the admin console, walk it through all six stages, and your test client
sees each stage change on their side — while having no way to move it themselves.

---

## Week 10 — Messaging

### Learn

- [Supabase Realtime — Postgres Changes](https://supabase.com/docs/guides/realtime/postgres-changes) (3 hours)
- [Supabase Database Functions](https://supabase.com/docs/guides/database/functions) (1 hour) — you already have `mark_thread_read` written; understand it

### Why

The last screen, and the one that changes how you work day to day: client questions stop
living in your inbox and start living against the bid they're about.

### Build

1. `app/admin/messages/page.js` — thread list from the `message_threads` view, messages
   from `messages`.
2. Remember the thread model: a thread is `(client_id, bid_id)`, and `bid_id = null` is the
   general thread. There is no threads table.
3. Sending inserts with `from_client = false` for you, `true` for them.
4. Opening a thread calls `mark_thread_read(client_id, bid_id)`.
5. `app/portal/messages/page.js` — same UI, their rows only.
6. Realtime subscription on `messages` so unread badges update without a refresh.
7. Unread count on the nav = `sum(unread_for_admin)`.

### Done when

Two browser windows side by side — you in one, a test client in the other. Send a message
from each. Both arrive without a refresh, and the unread badges are correct on both sides.

---

# PHASE FOUR — Launch (weeks 11–12)

---

## Week 11 — Email, domain, hardening

### Learn

- [Resend](https://resend.com/docs) (2 hours) — free tier, 3,000 emails a month
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions) (2 hours)
- [Supabase — inviting users](https://supabase.com/docs/reference/javascript/auth-admin-inviteuserbyemail) (1 hour)
- [Vercel — custom domains](https://vercel.com/docs/projects/domains/add-a-domain) (1 hour)

### Why

Two things left that a client actually touches: the invite email that gets them in, and
your own domain instead of a `.vercel.app` address. Both are trust.

### Build

1. **Buy the domain.** Namecheap, Cloudflare or Porkbun. **In your own name, your own
   account, your own card.** Keep the login.
2. Add it in Vercel and set the DNS records Vercel gives you.
3. Wire "Send invite" to `inviteUserByEmail`, redirecting to `/portal`. In the auth
   callback, create the profile row with the right `client_id` and `role = 'client'` —
   the invite arrives before the profile exists, and this is the step people get wrong.
4. Notify yourself when a client messages: an Edge Function calling Resend. Subject
   `New message from {client} — {thread}`. API key in Supabase secrets, never in git.
5. Set up SPF, DKIM and DMARC records for the domain, or your invites land in spam.
6. Security pass against `ENGINEER-HANDOFF.md` section 8, line by line.

### Done when

You invite a real second email address of your own from a live URL on your own domain. The
email arrives (not in spam), sets a password, and lands in a portal showing that client's
data and no one else's.

---

## Week 12 — Acceptance, backups, launch

### Learn

- [Supabase — Database backups](https://supabase.com/docs/guides/platform/backups) (1 hour)
- [Sentry for Next.js](https://docs.sentry.io/platforms/javascript/guides/nextjs/) (1 hour) — free tier

### Why

The difference between "it works on my machine" and "I can put a paying client on this" is
this week. Boring and non-negotiable.

### Build

1. Work `ENGINEER-HANDOFF.md` section 12 end to end. Every box. Write down what fails.
2. Fix what fails. Repeat until the list is clean.
3. **The isolation test, deliberately:** two clients with real data. Sign in as A. Using
   the browser's network tab, find a request and swap in B's id. It must refuse. Try
   fetching one of B's documents by its path. It must refuse. Do not skip this because it
   feels paranoid — it is the whole ballgame.
4. Confirm backups are on. Trigger one restore into a scratch project so you know it works.
5. Add Sentry so errors reach you instead of dying silently in a client's browser.
6. Test at 390px wide on your actual phone.
7. Confirm an empty database renders empty states and never crashes.
8. Onboard your first real client.

### Done when

Section 12 is fully ticked, on your own domain, and you have put a real client on it.

---

# Reference

## When you get stuck

1. Read the error message. Actually read it — the answer is usually in it.
2. Check the browser console (F12) and your terminal.
3. Search the exact error text plus "supabase" or "next.js".
4. Ask Claude or ChatGPT: paste the error, the code, and what you expected.
5. [Supabase Discord](https://discord.supabase.com) and
   [r/nextjs](https://reddit.com/r/nextjs) are both friendly to beginners.

**40 minutes is the limit.** Past that you're not learning, you're grinding.

## Free tiers, and when they run out

| Service | Free tier | When you'd pay |
|---|---|---|
| Supabase | 500MB database, 1GB storage | ~25/mo past that. Fine for a dozen clients. |
| Vercel | Personal projects, generous bandwidth | Commercial use technically wants Pro, ~20/mo |
| Resend | 3,000 emails/month | Far more than you'll send |
| GitHub | Unlimited private repos | Never, at your scale |
| Domain | — | £8–15/year |
| Sentry | 5,000 errors/month | Never, at your scale |

Realistically: **£15/year to start, £30–45/month once you're running properly.** Against
£5,000–15,000 for the same thing built for you.

## What you are deliberately not learning

So you don't feel behind: TypeScript, testing frameworks, Docker, Kubernetes, GraphQL,
Redux, CSS frameworks, CI/CD pipelines, microservices. All real, none needed here. Learn
them later if you enjoy this.

## If you fall behind

Falling behind is normal. Two rules:

- **Never skip weeks 1–3 or week 7.** Everything downstream assumes them.
- Weeks can stretch. Week 8 taking a fortnight is common and fine. Twelve weeks assumes 8–10
  hours; at 4 hours a week this is a six-month plan, and six months from now is still
  sooner than never.

## The honest risk

The screens and the schema are done, which removes most of the risk. What remains is
security — specifically client isolation. Get RLS right (week 7) and test it adversarially
(week 12) and you're fine. If you reach week 12 and the isolation test worries you, that is
the one thing worth paying an engineer a few hours to review. A short paid audit of your
RLS policies is money well spent, and it's a fraction of a full build.

## What to do this week

1. Install VS Code and Node.js.
2. Create GitHub and Supabase accounts.
3. Start freeCodeCamp Basic JavaScript.
4. Put four two-hour slots in your calendar and treat them like client meetings.
