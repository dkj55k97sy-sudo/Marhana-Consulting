# Making the client portal live

The portal front end is finished. To make it real it needs three things — accounts, a database, and file storage. Supabase provides all three, free at your volume. Budget about an hour.

---

## 1. Create the Supabase project

1. Go to **supabase.com** and sign up.
2. **New project**. Name it `marhana-portal`. Choose the London region. Save the database password somewhere safe.
3. Wait for it to finish provisioning (a minute or two).

## 2. Create the tables

1. In the left sidebar open **SQL Editor** → **New query**.
2. Open `supabase-schema.sql` from this project, copy the whole file, paste it in.
3. Press **Run**. You should see "Success".

This creates every table the portal reads, locks each one down so a client can only ever see their own rows, and creates a private storage bucket for documents.

## 3. Connect the portal to it

1. In Supabase go to **Project Settings** → **API**.
2. Copy the **Project URL** and the **anon public** key.
3. Open `portal.html` in a text editor. Near the top you will find this line — paste your values into it:

```js
window.MARHANA_PORTAL = {
  url: 'https://yourproject.supabase.co',
  anonKey: 'eyJhbGciOi...'
};
```

Save the file and re-upload it. Or send me the two values and I will paste them in and rebuild the site for you.

The anon key is designed to be public. The database rules from step 2 are what keep clients apart.

## 4. Add your first client

1. **Authentication** → **Users** → **Invite user**. Enter your client's email. They receive an email to set a password.
2. **SQL Editor**, and run this, edited for the client:

```sql
insert into clients (name) values ('Ashworth & Vale Ltd') returning id;
```

Copy the id it returns, then:

```sql
insert into profiles (id, client_id, full_name)
values ('<the auth user id from step 1>', '<the client id above>', 'Alan Vale');
```

The user id is shown in Authentication → Users.

3. Add their work, using the same client id:

```sql
insert into bids (client_id, title, buyer, deadline, value, status, stage, sort)
values ('<client id>', 'NHS Facilities Framework', 'NHS SBS', '24 Aug 2026', '£1.4m / 4 yrs', 'Drafting', 2, 1);

insert into tasks (client_id, label, due, sort)
values ('<client id>', 'Upload updated Health & Safety Policy', 'Due 20 Aug', 1);

insert into compliance_items (client_id, label, done, sort)
values ('<client id>', 'Employer''s liability insurance (£5m minimum)', true, 1);

insert into quotes (client_id, title, detail, amount, sort)
values ('<client id>', 'Full bid management', 'Drafting, QA and submission', '£4,800', 1);
```

`stage` drives the milestone tracker: 0 Kick-off, 1 Storyboarding, 2 Drafting, 3 Quality Assurance, 4 Client Sign-off, 5 Submission. Move a bid along by changing that number.

`status` drives the badge. Use `Drafting`, `Awaiting Review`, `Client Sign-off` or `Submitted`.

## 5. Test it

Deploy the site folder, open `/portal`, and sign in as the client. You should see their records and nothing else. Tick a checklist item, then refresh — it should stay ticked. Upload a file and check it appears in **Storage** → `client-documents`.

---

## What works once connected

- **Real sign-in.** Only invited users get in. Sessions persist across visits. Wrong details are refused.
- **Live data.** Bids, deadlines, to-do list, checklist, documents, quotes, invoices and messages all read from your database.
- **Client actions save.** Ticking a to-do or checklist item, accepting a quote, uploading a document and sending a message all write back.
- **Separation between clients.** Enforced by the database, not the page, so it holds even if someone inspects the code.
- **A Guide tab.** A plain-language explanation of every other tab, reachable any time from the sidebar — nothing to configure, it's built in.
- **A Profile tab.** The client can set their own name and their business's name, sector and contact details. Run `SUPABASE-CLIENT-PROFILE.sql` (same way as this file's schema) before this tab will save — otherwise the fields show but "Save changes" reports it couldn't save.

## What you still do from the Supabase dashboard

Adding bids, moving a bid to the next stage, issuing quotes and invoices, and replying to messages. That is deliberate — a full admin interface is a bigger build. If the SQL becomes tiresome, Supabase's **Table Editor** is a spreadsheet-style view you can type into directly, and I can build you a proper admin screen when you want one.

## Before real client documents go in

- Turn on daily backups in Supabase (Project Settings → Database).
- Publish a privacy policy covering what you store and for how long, and link it from the cookie banner.
- Consider requiring two-factor authentication for your own account.

## Until it is connected

The portal runs on demonstration data and any details sign you in — it shows a "Demonstration data" marker in the header so nobody mistakes it for live. Safe to show prospective clients, not safe to put real documents into.
