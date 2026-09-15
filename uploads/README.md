# Marhana & Co - Client Portal

## Overview

Enterprise B2B SaaS Client Portal built with **Next.js 15**, **TypeScript**, **Tailwind CSS**, and **Supabase**.

### Tech Stack

- **Framework:** Next.js 15 (App Router)
- **Language:** TypeScript (Strict Mode)
- **UI/Styling:** Tailwind CSS + Lucide React Icons
- **Backend & Auth:** Supabase (with SSR integration)
- **Security:** Row-Level Security (RLS) with strict tenant isolation

## Project Structure

```
marhana/
├── app/
│   ├── layout.tsx          # Global layout with fonts & styling
│   ├── globals.css         # Tailwind directives & global styles
│   ├── page.tsx            # Root page (placeholder)
│   ├── login/              # Login page (Phase 2)
│   └── portal/             # Protected portal routes (Phase 3+)
├── utils/
│   └── supabase/
│       ├── server.ts       # Server-side Supabase client
│       ├── client.ts       # Client-side Supabase client
│       └── middleware.ts   # Session refresh utility
├── middleware.ts           # Route protection & auth middleware
├── tailwind.config.ts      # Tailwind CSS configuration
├── tsconfig.json           # TypeScript configuration (strict mode)
└── package.json
```

## Setup Instructions

### 1. Clone & Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Copy `.env.local.example` to `.env.local` and add your Supabase credentials:

```bash
cp .env.local.example .env.local
```

Then update with your actual Supabase project URL and anon key from https://app.supabase.com/

### 3. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Design System

| Element            | Color      | Hex Value |
| ------------------ | ---------- | --------- |
| Background         | Soft Cream | #faf9f5   |
| Primary/Headers    | Dark Teal  | #113C39   |
| Accents/Hover      | Sand/Gold  | #F7F3EA   |

**Fonts:**
- Headings: Playfair Display (Serif)
- Body: Inter (Sans-Serif)

## Development Phases

- **Phase 1:** ✅ Project Initialization & Supabase SSR Setup
- **Phase 2:** Login Page
- **Phase 3:** Portal Layout & Sidebar
- **Phase 4:** Client Dashboard

## Security Notes

⚠️ **Important:** Always use the **public anon key** for frontend/client-side authentication. The Service Role Key must NEVER be exposed to the browser.

Database enforces RLS (Row-Level Security) ensuring clients only see data matching their `client_id`.

## Testing

Test user credentials:
- **Email:** amanmarhana1@gmail.com
- **Client:** testing 123 ltd

---

**Built for Marhana & Co Consulting** — A public-sector tender and bid writing consultancy.
