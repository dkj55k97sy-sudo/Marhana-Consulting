# Marhana & Co — Client Portal (source bundle)
This is the entire Next.js app source in one file, generated for handoff.

**To rebuild the project:**
1. Create a new Next.js 15 + Tailwind app (or an empty folder).
2. For each `### path/to/file` heading below, create that file at that path and paste in the code block that follows.
3. Create `.env.local` in the project root (see the template near the end) with your own Supabase project URL and anon key.
4. Add your own `logo-mark-t.png` and `logo-lockup-t.png` into `public/` (transparent-background PNGs) — these binary assets aren't included here since this is a text bundle.
5. `npm install` then `npm run dev`.

Not included: `node_modules/`, `.next/`, `package-lock.json`, `.env.local` (secrets), and the two logo PNGs (binary) — regenerate/reinstall those locally.

---
### `package.json`

```json
{
  "name": "marhana-saas-portal",
  "version": "1.0.0",
  "description": "Enterprise B2B SaaS Client Portal for Marhana & Co Consulting",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@supabase/ssr": "^0.12.4",
    "@supabase/supabase-js": "^2.43.0",
    "lucide-react": "^0.378.0",
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "tailwindcss": "^3.4.0"
  },
  "devDependencies": {
    "@tailwindcss/forms": "^0.5.7",
    "@types/node": "^20.10.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.56.0",
    "eslint-config-next": "^15.0.0",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.3.0"
  }
}
```

### `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": [
      "ES2020",
      "DOM",
      "DOM.Iterable"
    ],
    "module": "ESNext",
    "skipLibCheck": true,
    "strict": true,
    "esModuleInterop": true,
    "noEmitOnError": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitReturns": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": [
        "./*"
      ]
    },
    "allowJs": true
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": [
    "node_modules"
  ]
}
```

### `next.config.ts`

```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
```

### `next-env.d.ts`

```ts
/// <reference types="next" />
/// <reference types="next/image-types/global" />
/// <reference path="./.next/types/routes.d.ts" />

// NOTE: This file should not be edited
// see https://nextjs.org/docs/app/api-reference/config/typescript for more information.
```

### `tailwind.config.ts`

```ts
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        cream: "#F5F1E8",
        sand: "#EFE9DC",
        line: "#E9E1D0",
        "line-soft": "#EFE8D8",
        teal: "#113C39",
        "teal-deep": "#0C2C2A",
        "teal-mid": "#2E6A60",
        sage: "#9CBDB2",
        clay: "#B4694F",
        "clay-text": "#9A4E36",
        ink: "#1E2422",
        "ink-soft": "#3A423F",
        "ink-muted": "#5A625E",
        "ink-faint": "#8A8375",
      },
      fontFamily: {
        serif: ["Cormorant Garamond", "Garamond", "serif"],
        sans: ["Libre Franklin", "Helvetica Neue", "Arial", "sans-serif"],
      },
      boxShadow: {
        lift: "0 20px 40px rgba(17, 60, 57, 0.08)",
        hover: "0 28px 56px -28px rgba(17, 60, 57, 0.30)",
      },
    },
  },
  plugins: [],
};

export default config;
```

### `postcss.config.js`

```js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
```

### `middleware.ts`

```ts
import { type NextRequest, NextResponse } from "next/server";
import { updateSession } from "@/utils/supabase/middleware";

export async function middleware(request: NextRequest) {
  const { response, session } = await updateSession(request);

  if (request.nextUrl.pathname.startsWith("/portal") && !session) {
    const loginUrl = new URL("/login", request.url);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
};
```

### `app/layout.tsx`

```tsx
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Marhana & Co | Client Portal",
  description: "Enterprise SaaS Client Portal for Marhana & Co Consulting",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-cream font-sans text-ink">
        {children}
      </body>
    </html>
  );
}
```

### `app/page.tsx`

```tsx
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    router.push('/login');
  }, [router]);

  return null;
}
```

### `app/globals.css`

```css
/* =====================================================================
   Marhana & Co — portal theme
   Drop-in replacement for app/globals.css in your Next.js project.
   Matches marhanaconsulting.com exactly: same fonts, same palette.
   ===================================================================== */

@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400&family=Libre+Franklin:wght@300;400;500;600&display=swap');

:root {
  /* Surfaces */
  --cream:        #F5F1E8;   /* page background */
  --card:         #FFFFFF;   /* card surface */
  --sand:         #EFE9DC;   /* secondary band */
  --line:         #E9E1D0;   /* card border */
  --line-soft:    #EFE8D8;   /* row divider */

  /* Brand */
  --teal:         #113C39;   /* primary */
  --teal-deep:    #0C2C2A;   /* sidebar, dark sections */
  --teal-mid:     #2E6A60;   /* accent on light backgrounds */
  --sage:         #9CBDB2;   /* accent on dark backgrounds */

  /* Text */
  --ink:          #1E2422;
  --ink-soft:     #3A423F;
  --ink-muted:    #5A625E;
  --ink-faint:    #8A8375;

  /* Status — used sparingly, only for "needs action" */
  --clay:         #B4694F;
  --clay-text:    #9A4E36;

  --shadow-lift:  0 20px 40px rgba(17, 60, 57, 0.08);
  --shadow-hover: 0 28px 56px -28px rgba(17, 60, 57, 0.30);
}

html, body {
  background: var(--cream);
  color: var(--ink);
  font-family: 'Libre Franklin', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 400;
  -webkit-font-smoothing: antialiased;
}

h1, h2, h3, h4 {
  font-family: 'Cormorant Garamond', Garamond, 'Times New Roman', serif;
  font-weight: 500;
  letter-spacing: -0.004em;
  margin: 0;
}

/* Cormorant sets small and light — these sizes compensate. */
h1 { font-size: clamp(30px, 3.2vw, 40px); line-height: 1.08; color: var(--teal); }
h2 { font-size: clamp(24px, 2.4vw, 30px); line-height: 1.14; color: var(--teal); }
h3 { font-size: 23px; font-weight: 600; color: var(--teal); }

p  { line-height: 1.7; color: var(--ink-soft); }

::selection { background: var(--teal); color: #F7F3EA; }

a          { color: var(--teal-mid); text-decoration: none; }
a:hover    { color: var(--teal); }

/* =====================================================================
   Components — apply these class names in your JSX.
   ===================================================================== */
@layer components {

  /* ---- Card ---------------------------------------------------- */
  .m-card {
    background: var(--card);
    border: 1px solid var(--line);
    border-radius: 14px;
    padding: 28px;
    transition: box-shadow .4s cubic-bezier(.19,1,.22,1),
                transform  .4s cubic-bezier(.19,1,.22,1);
  }
  .m-card-hover:hover {
    transform: translateY(-3px);
    box-shadow: var(--shadow-hover);
  }

  /* ---- Statistic ----------------------------------------------- */
  .m-stat-label {
    font-size: 12px; letter-spacing: .14em; text-transform: uppercase;
    color: var(--ink-faint); margin-bottom: 14px;
  }
  .m-stat-figure {
    font-family: 'Cormorant Garamond', Garamond, serif;
    font-size: 52px; line-height: 1; color: var(--teal);
  }
  .m-stat-sub   { margin-top: 10px; font-size: 13.5px; color: var(--teal-mid); }
  .m-stat-alert { margin-top: 10px; font-size: 13.5px; color: var(--clay); }

  /* ---- Sidebar ------------------------------------------------- */
  .m-sidebar {
    background: var(--teal-deep);
    padding: 30px 20px;
    display: flex; flex-direction: column; gap: 34px;
    position: sticky; top: 0; height: 100vh;
  }
  .m-nav-item {
    display: flex; align-items: center; gap: 13px;
    padding: 13px 16px; border-radius: 8px;
    color: rgba(247,243,234,.7); font-size: 14px; cursor: pointer;
    transition: background-color .25s ease, color .25s ease;
  }
  .m-nav-item:hover {
    background-color: rgba(247,243,234,.06);
    color: #F7F3EA;
  }
  .m-nav-item-active {
    background-color: rgba(247,243,234,.10);
    color: #F7F3EA;
    box-shadow: inset 3px 0 0 var(--sage);   /* the signature detail */
  }

  /* ---- Header (frosted, matches the site) ---------------------- */
  .m-header {
    position: sticky; top: 0; z-index: 20;
    display: flex; align-items: center; justify-content: space-between;
    gap: 20px; padding: 22px 40px;
    background: rgba(245,241,232,.86);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-bottom: 1px solid #E4DCCB;
  }

  /* ---- Buttons ------------------------------------------------- */
  .m-btn {
    padding: 14px 26px; border: none; border-radius: 8px;
    background: var(--teal); color: #F7F3EA;
    font-size: 12px; letter-spacing: .2em; text-transform: uppercase;
    cursor: pointer;
    transition: background-color .25s ease, transform .25s ease;
  }
  .m-btn:hover     { background: var(--teal-deep); transform: translateY(-1px); }
  .m-btn-quiet {
    padding: 9px 16px; border: 1px solid #E0D8C7; border-radius: 8px;
    background: var(--card); color: var(--ink-muted);
    font-size: 12px; letter-spacing: .14em; text-transform: uppercase;
    cursor: pointer; transition: border-color .25s ease, color .25s ease;
  }
  .m-btn-quiet:hover { border-color: var(--teal); color: var(--teal); }

  /* ---- Status badges ------------------------------------------- */
  .m-badge {
    font-size: 11px; letter-spacing: .08em; text-transform: uppercase;
    padding: 6px 12px; border-radius: 20px; white-space: nowrap;
  }
  .m-badge-progress { background: rgba(46,106,96,.12);  color: var(--teal-mid); }
  .m-badge-action   { background: rgba(180,105,79,.14); color: var(--clay-text); }
  .m-badge-done     { background: var(--teal);          color: #F7F3EA; }

  /* ---- Progress bar ------------------------------------------- */
  .m-progress      { height: 6px; border-radius: 6px; background: #EDE6D6; overflow: hidden; }
  .m-progress-fill { height: 100%; background: linear-gradient(90deg, var(--teal-mid), #4F8C80); }

  /* ---- Form fields -------------------------------------------- */
  .m-label {
    display: block; font-size: 12px; letter-spacing: .14em;
    text-transform: uppercase; color: var(--ink-muted); margin-bottom: 8px;
  }
  .m-input {
    width: 100%; padding: 15px 16px;
    border: 1px solid #D6CFBF; border-radius: 8px;
    background: var(--card); font-size: 15px; color: var(--ink);
    transition: border-color .25s ease;
  }
  .m-input:focus { outline: none; border-color: var(--teal-mid); }

  /* ---- List row ------------------------------------------------ */
  .m-row { padding: 16px 0; border-top: 1px solid var(--line-soft); }

  /* ---- Skeleton loader ---------------------------------------- */
  .m-skeleton {
    background: linear-gradient(90deg, #EDE6D6 25%, #F5F1E8 50%, #EDE6D6 75%);
    background-size: 200% 100%;
    animation: m-shimmer 1.5s infinite;
    border-radius: 6px;
  }
  @keyframes m-shimmer {
    from { background-position: 200% 0; }
    to   { background-position: -200% 0; }
  }

  /* ---- Section entrance --------------------------------------- */
  .m-rise { animation: m-rise .6s cubic-bezier(.19,1,.22,1) both; }
  @keyframes m-rise {
    from { opacity: 0; transform: translateY(14px); }
    to   { opacity: 1; transform: none; }
  }
}
```

### `app/login/page.tsx`

```tsx
'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { createClient } from '@/utils/supabase/client';
import { Mail, Lock, AlertCircle, Loader2, CheckCircle2 } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [checkingAuth, setCheckingAuth] = useState(true);

  useEffect(() => {
    let isMounted = true;

    const checkAuth = async () => {
      try {
        const { data } = await supabase.auth.getSession();
        if (!isMounted) return;

        if (data?.session) {
          router.replace('/portal');
          return;
        }
      } catch (err) {
        console.error('Auth check error:', err);
      } finally {
        if (isMounted) {
          setCheckingAuth(false);
        }
      }
    };

    const timer = window.setTimeout(() => {
      if (isMounted) {
        setCheckingAuth(false);
      }
    }, 2000);

    checkAuth();

    return () => {
      isMounted = false;
      window.clearTimeout(timer);
    };
  }, [router, supabase]);

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setLoading(true);

    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        console.error('Sign-in error:', error);
        setError(error.message);
        setLoading(false);
        return;
      }

      router.push('/portal');
    } catch (err) {
      console.error('Sign-in threw:', err);
      setError('An unexpected error occurred. Please try again.');
      setLoading(false);
    }
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setLoading(true);

    try {
      const redirectTo = `${window.location.origin}/auth/confirm`;

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: redirectTo,
        },
      });

      if (error) {
        setError(error.message);
        setLoading(false);
        return;
      }

      if (data.session) {
        router.push('/portal');
        return;
      }

      setSuccess('Account created successfully. Check your email to confirm your invitation and finish signing in.');
      setLoading(false);
      setMode('signin');
    } catch (err) {
      setError('Signup failed. Please try again or ask for a fresh invite.');
      setLoading(false);
    }
  };

  if (checkingAuth) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-cream">
        <div className="text-center">
          <Loader2 className="mb-4 inline-block h-8 w-8 animate-spin text-teal" />
          <p className="text-ink-muted">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-cream">
      {/* Left Side - Branding */}
      <div className="hidden w-1/2 flex-col justify-between bg-teal-deep p-12 text-cream lg:flex">
        <div>
          <Image src="/logo-lockup-t.png" alt="Marhana & Co Consulting" width={1254} height={1254} className="h-auto w-[180px]" priority />
          <p className="mt-4 text-lg text-cream opacity-80">Client Portal</p>
        </div>

        <div className="max-w-md space-y-6">
          <div>
            <h2 className="text-cream">Enterprise Tenders & Bids</h2>
            <p className="mt-3 text-cream opacity-80">
              Manage your bids, compliance documents, and commercial activities in one secure platform.
            </p>
          </div>

          <div className="space-y-4 pt-4">
            <div className="flex items-start gap-3">
              <div className="mt-1 h-2 w-2 rounded-full bg-sage" />
              <p className="text-cream">Secure tenant isolation with RLS</p>
            </div>
            <div className="flex items-start gap-3">
              <div className="mt-1 h-2 w-2 rounded-full bg-sage" />
              <p className="text-cream">Real-time bid tracking</p>
            </div>
            <div className="flex items-start gap-3">
              <div className="mt-1 h-2 w-2 rounded-full bg-sage" />
              <p className="text-cream">Document vault & compliance management</p>
            </div>
          </div>
        </div>

        <p className="text-sm text-cream opacity-60">
          © 2026 Marhana & Co Consulting. All rights reserved.
        </p>
      </div>

      {/* Right Side - Login Form */}
      <div className="flex w-full items-center justify-center p-6 lg:w-1/2 lg:p-12">
        <div className="w-full max-w-[380px]">
          {/* Mobile Branding */}
          <div className="mb-8 lg:hidden">
            <Image src="/logo-mark-t.png" alt="Marhana & Co" width={1320} height={625} className="h-10 w-auto" priority />
            <p className="mt-2 text-ink-muted">Client Portal</p>
          </div>

          {/* Login Card */}
          <div className="m-card">
            <div className="mb-6 flex rounded-lg bg-sand p-1">
              <button
                type="button"
                onClick={() => {
                  setMode('signin');
                  setError(null);
                  setSuccess(null);
                }}
                className={`flex-1 rounded-md px-4 py-2 text-sm font-medium transition-all ${
                  mode === 'signin' ? 'bg-white text-teal shadow-sm' : 'text-ink-muted'
                }`}
              >
                Sign In
              </button>
              <button
                type="button"
                onClick={() => {
                  setMode('signup');
                  setError(null);
                  setSuccess(null);
                }}
                className={`flex-1 rounded-md px-4 py-2 text-sm font-medium transition-all ${
                  mode === 'signup' ? 'bg-white text-teal shadow-sm' : 'text-ink-muted'
                }`}
              >
                Sign Up
              </button>
            </div>

            <h2 className="text-teal">
              {mode === 'signin' ? 'Welcome Back' : 'Create Account'}
            </h2>
            <p className="mt-2 text-ink-muted">
              {mode === 'signin'
                ? 'Sign in to your account to continue'
                : 'Set up your password to finish your invitation'}
            </p>

            {error && (
              <div className="mt-6 flex gap-3 rounded-lg bg-clay/[0.14] p-4">
                <AlertCircle className="h-5 w-5 flex-shrink-0 text-clay-text" />
                <p className="text-sm text-clay-text">{error}</p>
              </div>
            )}

            {success && (
              <div className="mt-6 flex gap-3 rounded-lg bg-teal-mid/[0.12] p-4">
                <CheckCircle2 className="h-5 w-5 flex-shrink-0 text-teal-mid" />
                <p className="text-sm text-teal-mid">{success}</p>
              </div>
            )}

            {/* Login Form */}
            <form onSubmit={mode === 'signin' ? handleSignIn : handleSignUp} className="mt-6 space-y-4">
              {/* Email Field */}
              <div>
                <label className="m-label">Email Address</label>
                <div className="m-input mt-2 flex items-center gap-3 focus-within:border-teal-mid">
                  <Mail className="h-5 w-5 text-ink-faint" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="you@example.com"
                    className="w-full border-0 bg-transparent p-0 font-sans placeholder-ink-faint outline-none"
                    disabled={loading}
                    required
                  />
                </div>
              </div>

              {/* Password Field */}
              <div>
                <label className="m-label">Password</label>
                <div className="m-input mt-2 flex items-center gap-3 focus-within:border-teal-mid">
                  <Lock className="h-5 w-5 text-ink-faint" />
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full border-0 bg-transparent p-0 font-sans placeholder-ink-faint outline-none"
                    disabled={loading}
                    required
                  />
                </div>
              </div>

              {/* Sign In / Sign Up Button */}
              <button
                type="submit"
                disabled={loading}
                className="m-btn mt-6 flex w-full items-center justify-center gap-2 disabled:cursor-not-allowed disabled:opacity-70"
              >
                {loading ? (
                  <>
                    <Loader2 className="h-5 w-5 animate-spin" />
                    {mode === 'signin' ? 'Signing in...' : 'Creating account...'}
                  </>
                ) : mode === 'signin' ? (
                  'Sign In'
                ) : (
                  'Create Account'
                )}
              </button>
            </form>

            {/* Demo Credentials */}
            <div className="mt-8 rounded-lg bg-sand p-4">
              <p className="text-xs font-semibold text-ink uppercase tracking-wide">
                Test Credentials
              </p>
              <p className="mt-2 text-sm text-ink-muted">
                <span className="font-mono">amanmarhana1@gmail.com</span>
              </p>
            </div>
          </div>

          {/* Footer Note */}
          <p className="mt-6 text-center text-sm text-ink-muted">
            Need help? Contact{' '}
            <a href="mailto:support@marhana.co" className="font-semibold hover:underline">
              support@marhana.co
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
```

### `app/auth/confirm/route.ts`

```ts
import { type EmailOtpType } from '@supabase/supabase-js';
import { type NextRequest, NextResponse } from 'next/server';

import { createClient } from '@/utils/supabase/server';

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url);
  const token_hash = searchParams.get('token_hash');
  const type = searchParams.get('type') as EmailOtpType | null;
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/portal';

  if (token_hash && type) {
    const supabase = await createClient();
    const { error } = await supabase.auth.verifyOtp({
      type,
      token_hash,
    });

    if (!error) {
      return NextResponse.redirect(new URL(next, origin));
    }
  }

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      return NextResponse.redirect(new URL(next, origin));
    }
  }

  return NextResponse.redirect(new URL('/login?error=auth_failed', origin));
}
```

### `app/portal/layout.tsx`

```tsx
'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { usePathname } from 'next/navigation';
import Image from 'next/image';
import Link from 'next/link';
import { createClient } from '@/utils/supabase/client';
import {
  LayoutDashboard,
  FileText,
  FolderOpen,
  CheckCircle2,
  DollarSign,
  LogOut,
  Menu,
  X,
  Loader2,
  type LucideIcon,
} from 'lucide-react';

interface NavLink {
  href: string;
  label: string;
  icon: LucideIcon;
}

const navLinks: NavLink[] = [
  {
    href: '/portal',
    label: 'Dashboard',
    icon: LayoutDashboard,
  },
  {
    href: '/portal/bids',
    label: 'Bids & Tenders',
    icon: FileText,
  },
  {
    href: '/portal/documents',
    label: 'Document Vault',
    icon: FolderOpen,
  },
  {
    href: '/portal/compliance',
    label: 'Compliance',
    icon: CheckCircle2,
  },
  {
    href: '/portal/commercials',
    label: 'Commercials',
    icon: DollarSign,
  },
];

export default function PortalLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const supabase = createClient();

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [user, setUser] = useState<any>(null);
  const [clientName, setClientName] = useState<string>('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initializePortal = async () => {
      try {
        const { data, error: sessionError } = await supabase.auth.getSession();

        if (sessionError || !data.session) {
          router.push('/login');
          return;
        }

        setUser(data.session.user);

        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('client_id')
          .eq('id', data.session.user.id)
          .single();

        if (profileError || !profileData) {
          console.error('Error fetching profile:', profileError);
          setClientName('Client Portal');
          setLoading(false);
          return;
        }

        const { data: clientData, error: clientError } = await supabase
          .from('clients')
          .select('company_name')
          .eq('id', profileData.client_id)
          .single();

        if (clientError || !clientData) {
          console.error('Error fetching client:', clientError);
          setClientName('Client Portal');
        } else {
          setClientName(clientData.company_name || 'Client Portal');
        }
      } catch (err) {
        console.error('Portal initialization error:', err);
        setClientName('Client Portal');
      } finally {
        setLoading(false);
      }
    };

    initializePortal();
  }, [router, supabase]);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push('/login');
  };

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-cream">
        <div className="text-center">
          <Loader2 className="mb-4 inline-block h-8 w-8 animate-spin text-teal" />
          <p className="text-ink-muted">Loading portal...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-cream">
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-30 bg-black bg-opacity-50 transition-opacity duration-300 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`m-sidebar fixed left-0 top-0 z-40 h-screen w-64 transition-transform duration-300 ease-in-out lg:relative lg:translate-x-0 ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Sidebar Header */}
        <div className="flex items-center justify-between">
          <Image src="/logo-mark-t.png" alt="Marhana & Co" width={1320} height={625} className="h-12 w-auto" priority />
          <button
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden p-1 text-cream hover:bg-white hover:bg-opacity-10 rounded transition-colors"
          >
            <X className="h-6 w-6" strokeWidth={1.6} />
          </button>
        </div>

        {/* Navigation Links */}
        <nav className="flex-1 space-y-1 overflow-y-auto">
          {navLinks.map((link) => {
            const isActive = pathname === link.href;
            const Icon = link.icon;

            return (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setSidebarOpen(false)}
                className={isActive ? 'm-nav-item m-nav-item-active' : 'm-nav-item'}
              >
                <Icon size={17} strokeWidth={1.6} className="flex-shrink-0" />
                <span>{link.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Sidebar Footer */}
        <div>
          <div className="mb-4 text-xs text-sand opacity-70">
            <p className="truncate">Signed in as</p>
            <p className="truncate font-mono text-xs">{user?.email}</p>
          </div>
          <button
            onClick={handleLogout}
            className="m-nav-item w-full"
          >
            <LogOut size={17} strokeWidth={1.6} />
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1">
        {/* Top Bar */}
        <header className="m-header">
          <button
            onClick={() => setSidebarOpen(true)}
            className="lg:hidden p-2 text-teal hover:bg-sand rounded-lg transition-colors"
          >
            <Menu className="h-6 w-6" />
          </button>

          <div className="hidden lg:block">
            <h1>{clientName}</h1>
          </div>

          <div className="text-right">
            <p className="text-sm text-ink-muted">Welcome back</p>
            <p className="font-medium text-teal">{user?.email}</p>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
```

### `app/portal/page.tsx`

```tsx
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { Suspense } from 'react';
import { TrendingUp, CheckCircle, FileText, Clock } from 'lucide-react';

export const dynamic = 'force-dynamic';

async function getActiveBids() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: bidsData, error: bidsError } = await supabase
      .from('bids')
      .select('id, title, status, bid_amount, deadline')
      .eq('client_id', profileData.client_id)
      .in('status', ['active', 'in_progress', 'Drafting'])
      .order('deadline', { ascending: true })
      .limit(5);

    if (bidsError) {
      console.error('Failed to fetch active bids:', bidsError.message);
      return [];
    }

    return bidsData || [];
  } catch (error) {
    console.error('Active bids fetch failed:', error);
    return [];
  }
}

async function getPendingTasks() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: tasksData, error: tasksError } = await supabase
      .from('tasks')
      .select('id, title, status, due_date, priority')
      .eq('client_id', profileData.client_id)
      .in('status', ['pending', 'in_progress'])
      .order('due_date', { ascending: true })
      .limit(5);

    if (tasksError) {
      console.error('Failed to fetch pending tasks:', tasksError.message);
      return [];
    }

    return tasksData || [];
  } catch (error) {
    console.error('Pending tasks fetch failed:', error);
    return [];
  }
}

async function getRecentDocuments() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: docsData, error: docsError } = await supabase
      .from('documents')
      .select('id, name, document_type, created_at')
      .eq('client_id', profileData.client_id)
      .order('created_at', { ascending: false })
      .limit(5);

    if (docsError) {
      console.error('Failed to fetch recent documents:', docsError.message);
      return [];
    }

    return docsData || [];
  } catch (error) {
    console.error('Recent documents fetch failed:', error);
    return [];
  }
}

function getStatusBadgeClass(status: string): string {
  const s = status?.toLowerCase() || '';
  if (s.includes('completed') || s.includes('won')) return 'm-badge m-badge-done';
  if (s.includes('pending')) return 'm-badge m-badge-action';
  return 'm-badge m-badge-progress';
}

async function ActiveBidsWidget() {
  const bids = await getActiveBids();

  return (
    <div className="m-card">
      <div className="mb-6 flex items-center justify-between">
        <h3>Active Bids</h3>
        <TrendingUp className="h-5 w-5 text-sage" />
      </div>

      {bids.length === 0 ? (
        <p className="text-ink-muted">No active bids at the moment</p>
      ) : (
        <div className="space-y-3">
          {bids.map((bid: any) => (
            <div
              key={bid.id}
              className="flex items-center justify-between border-b border-line-soft pb-3 last:border-0"
            >
              <div>
                <p className="font-medium text-ink">{bid.title}</p>
                <p className="text-xs text-ink-faint">
                  {bid.deadline ? new Date(bid.deadline).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : 'No deadline'}
                </p>
              </div>
              <span className={getStatusBadgeClass(bid.status)}>
                {bid.status}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

async function PendingTasksWidget() {
  const tasks = await getPendingTasks();

  return (
    <div className="m-card">
      <div className="mb-6 flex items-center justify-between">
        <h3>Pending Tasks</h3>
        <Clock className="h-5 w-5 text-sage" />
      </div>

      {tasks.length === 0 ? (
        <p className="text-ink-muted">No pending tasks</p>
      ) : (
        <div className="space-y-3">
          {tasks.map((task: any) => (
            <div
              key={task.id}
              className="rounded-lg border-l-4 border-clay bg-sand p-3"
            >
              <p className="font-medium text-ink">{task.title}</p>
              <div className="mt-2 flex items-center justify-between">
                <p className="text-xs text-ink-muted">
                  Due: {task.due_date ? new Date(task.due_date).toLocaleDateString() : 'No due date'}
                </p>
                <span className="m-badge m-badge-action">
                  {task.status}
                </span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

async function RecentDocumentsWidget() {
  const documents = await getRecentDocuments();

  return (
    <div className="m-card md:col-span-2">
      <div className="mb-6 flex items-center justify-between">
        <h3>Recent Documents</h3>
        <FileText className="h-5 w-5 text-sage" />
      </div>

      {documents.length === 0 ? (
        <p className="text-ink-muted">No documents uploaded yet</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b-2 border-line text-left font-semibold text-ink-muted">
                <th className="pb-3">Document Name</th>
                <th className="pb-3">Type</th>
                <th className="pb-3">Uploaded</th>
              </tr>
            </thead>
            <tbody>
              {documents.map((doc: any) => (
                <tr key={doc.id} className="border-b border-line-soft hover:bg-sand">
                  <td className="py-3 font-medium text-ink">{doc.name}</td>
                  <td className="py-3 text-ink-muted">
                    <span className="rounded-full bg-teal-mid/10 px-3 py-1 text-xs text-teal-mid">
                      {doc.document_type || 'General'}
                    </span>
                  </td>
                  <td className="py-3 text-ink-muted">
                    {doc.created_at ? new Date(doc.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : 'Unknown'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default function PortalPage() {
  return (
    <div className="space-y-8 p-8">
      {/* Header */}
      <div>
        <h1>Dashboard</h1>
        <p className="mt-2 text-ink-muted">Manage your bids, documents, and compliance in one place</p>
      </div>

      {/* Stats Overview */}
      <div className="grid gap-6 md:grid-cols-3">
        <Suspense fallback={<div className="m-card m-skeleton h-32" />}>
          <ActiveBidsWidget />
        </Suspense>

        <Suspense fallback={<div className="m-card m-skeleton h-32" />}>
          <PendingTasksWidget />
        </Suspense>

        <div className="m-card">
          <div className="flex items-center justify-between">
            <div>
              <div className="m-stat-label">Compliance Status</div>
              <div className="m-stat-figure">100%</div>
              <div className="m-stat-sub flex items-center gap-1">
                <CheckCircle className="h-3 w-3" />
                All compliant
              </div>
            </div>
            <CheckCircle className="h-8 w-8 text-sage" />
          </div>
        </div>
      </div>

      {/* Documents Section */}
      <Suspense fallback={<div className="m-card m-skeleton h-48" />}>
        <RecentDocumentsWidget />
      </Suspense>
    </div>
  );
}
```

### `app/portal/bids/page.tsx`

```tsx
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { Suspense } from 'react';
import { FileText } from 'lucide-react';

export const dynamic = 'force-dynamic';

async function getBids() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: bidsData, error: bidsError } = await supabase
      .from('bids')
      .select('id, title, status, bid_amount, deadline')
      .eq('client_id', profileData.client_id)
      .order('deadline', { ascending: true });

    if (bidsError) {
      console.error('Failed to fetch bids:', bidsError.message);
      return [];
    }

    return bidsData || [];
  } catch (error) {
    console.error('Bids fetch failed:', error);
    return [];
  }
}

function getStatusBadgeClass(status: string): string {
  const s = status?.toLowerCase() || '';
  if (s.includes('completed') || s.includes('won')) return 'm-badge m-badge-done';
  if (s.includes('pending')) return 'm-badge m-badge-action';
  return 'm-badge m-badge-progress';
}

function formatCurrency(amount: number | null): string {
  if (amount === null || amount === undefined) return '—';
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(amount);
}

async function BidsTable() {
  const bids = await getBids();

  return (
    <div className="m-card">
      <div className="mb-6 flex items-center justify-between">
        <h3>All Bids</h3>
        <FileText className="h-5 w-5 text-sage" />
      </div>

      {bids.length === 0 ? (
        <p className="text-ink-muted">No bids on file yet</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b-2 border-line text-left font-semibold text-ink-muted">
                <th className="pb-3">Title</th>
                <th className="pb-3">Status</th>
                <th className="pb-3">Value</th>
                <th className="pb-3">Deadline</th>
              </tr>
            </thead>
            <tbody>
              {bids.map((bid: any) => (
                <tr key={bid.id} className="border-b border-line-soft hover:bg-sand">
                  <td className="py-3 font-medium text-ink">{bid.title}</td>
                  <td className="py-3">
                    <span className={getStatusBadgeClass(bid.status)}>{bid.status}</span>
                  </td>
                  <td className="py-3 text-ink-muted">{formatCurrency(bid.bid_amount)}</td>
                  <td className="py-3 text-ink-muted">
                    {bid.deadline ? new Date(bid.deadline).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : 'No deadline'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default function BidsPage() {
  return (
    <div className="space-y-8 p-8">
      <div>
        <h1>Bids &amp; Tenders</h1>
        <p className="mt-2 text-ink-muted">Every bid on file, past and present</p>
      </div>

      <Suspense fallback={<div className="m-card m-skeleton h-64" />}>
        <BidsTable />
      </Suspense>
    </div>
  );
}
```

### `app/portal/documents/page.tsx`

```tsx
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { Suspense } from 'react';
import { FolderOpen } from 'lucide-react';

export const dynamic = 'force-dynamic';

async function getDocuments() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: docsData, error: docsError } = await supabase
      .from('documents')
      .select('id, name, document_type, created_at')
      .eq('client_id', profileData.client_id)
      .order('created_at', { ascending: false });

    if (docsError) {
      console.error('Failed to fetch documents:', docsError.message);
      return [];
    }

    return docsData || [];
  } catch (error) {
    console.error('Documents fetch failed:', error);
    return [];
  }
}

async function DocumentsTable() {
  const documents = await getDocuments();

  return (
    <div className="m-card">
      <div className="mb-6 flex items-center justify-between">
        <h3>All Documents</h3>
        <FolderOpen className="h-5 w-5 text-sage" />
      </div>

      {documents.length === 0 ? (
        <p className="text-ink-muted">No documents uploaded yet</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b-2 border-line text-left font-semibold text-ink-muted">
                <th className="pb-3">Document Name</th>
                <th className="pb-3">Type</th>
                <th className="pb-3">Uploaded</th>
              </tr>
            </thead>
            <tbody>
              {documents.map((doc: any) => (
                <tr key={doc.id} className="border-b border-line-soft hover:bg-sand">
                  <td className="py-3 font-medium text-ink">{doc.name}</td>
                  <td className="py-3 text-ink-muted">
                    <span className="rounded-full bg-teal-mid/10 px-3 py-1 text-xs text-teal-mid">
                      {doc.document_type || 'General'}
                    </span>
                  </td>
                  <td className="py-3 text-ink-muted">
                    {doc.created_at ? new Date(doc.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : 'Unknown'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default function DocumentsPage() {
  return (
    <div className="space-y-8 p-8">
      <div>
        <h1>Document Vault</h1>
        <p className="mt-2 text-ink-muted">Every document on file for your account</p>
      </div>

      <Suspense fallback={<div className="m-card m-skeleton h-64" />}>
        <DocumentsTable />
      </Suspense>
    </div>
  );
}
```

### `app/portal/compliance/page.tsx`

```tsx
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { Suspense } from 'react';
import { CheckCircle, ShieldCheck } from 'lucide-react';

export const dynamic = 'force-dynamic';

async function getComplianceItems() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: itemsData, error: itemsError } = await supabase
      .from('compliance_items')
      .select('id, label, done')
      .eq('client_id', profileData.client_id)
      .order('label', { ascending: true });

    if (itemsError) {
      console.error('Failed to fetch compliance items:', itemsError.message);
      return [];
    }

    return itemsData || [];
  } catch (error) {
    console.error('Compliance items fetch failed:', error);
    return [];
  }
}

async function ComplianceOverview() {
  const items = await getComplianceItems();
  const total = items.length;
  const done = items.filter((item: any) => item.done).length;
  const pct = total > 0 ? Math.round((done / total) * 100) : 100;

  return (
    <div className="m-card">
      <div className="flex items-center justify-between">
        <div>
          <div className="m-stat-label">Compliance Status</div>
          <div className="m-stat-figure">{pct}%</div>
          <div className={pct === 100 ? 'm-stat-sub flex items-center gap-1' : 'm-stat-alert flex items-center gap-1'}>
            <CheckCircle className="h-3 w-3" />
            {total === 0 ? 'No items on file' : `${done} of ${total} requirements met`}
          </div>
        </div>
        <ShieldCheck className="h-8 w-8 text-sage" />
      </div>
    </div>
  );
}

async function ComplianceList() {
  const items = await getComplianceItems();

  return (
    <div className="m-card">
      <div className="mb-6 flex items-center justify-between">
        <h3>Requirements</h3>
      </div>

      {items.length === 0 ? (
        <p className="text-ink-muted">No compliance requirements on file</p>
      ) : (
        <div className="space-y-3">
          {items.map((item: any) => (
            <div
              key={item.id}
              className="flex items-center justify-between border-b border-line-soft pb-3 last:border-0"
            >
              <p className="font-medium text-ink">{item.label}</p>
              <span className={item.done ? 'm-badge m-badge-done' : 'm-badge m-badge-action'}>
                {item.done ? 'Complete' : 'Action Needed'}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default function CompliancePage() {
  return (
    <div className="space-y-8 p-8">
      <div>
        <h1>Compliance</h1>
        <p className="mt-2 text-ink-muted">Track the requirements that keep your account in good standing</p>
      </div>

      <Suspense fallback={<div className="m-card m-skeleton h-32" />}>
        <ComplianceOverview />
      </Suspense>

      <Suspense fallback={<div className="m-card m-skeleton h-64" />}>
        <ComplianceList />
      </Suspense>
    </div>
  );
}
```

### `app/portal/commercials/page.tsx`

```tsx
import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { Suspense } from 'react';
import { DollarSign } from 'lucide-react';

export const dynamic = 'force-dynamic';

async function getInvoices() {
  try {
    const supabase = await createClient();

    const { data: sessionData } = await supabase.auth.getSession();
    if (!sessionData?.session) {
      redirect('/login');
    }

    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('client_id')
      .eq('id', sessionData.session.user.id)
      .single();

    if (profileError || !profileData?.client_id) {
      return [];
    }

    const { data: invoicesData, error: invoicesError } = await supabase
      .from('invoices')
      .select('id, amount, status, ref, issued')
      .eq('client_id', profileData.client_id)
      .order('issued', { ascending: false });

    if (invoicesError) {
      console.error('Failed to fetch invoices:', invoicesError.message);
      return [];
    }

    return invoicesData || [];
  } catch (error) {
    console.error('Invoices fetch failed:', error);
    return [];
  }
}

function getStatusBadgeClass(status: string): string {
  const s = status?.toLowerCase() || '';
  if (s.includes('paid') || s.includes('completed') || s.includes('won')) return 'm-badge m-badge-done';
  if (s.includes('pending') || s.includes('overdue') || s.includes('due')) return 'm-badge m-badge-action';
  return 'm-badge m-badge-progress';
}

function formatCurrency(amount: number | null): string {
  if (amount === null || amount === undefined) return '—';
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(amount);
}

async function CommercialsSummary() {
  const invoices = await getInvoices();
  const total = invoices.reduce((sum: number, inv: any) => sum + (inv.amount || 0), 0);

  return (
    <div className="m-card">
      <div className="flex items-center justify-between">
        <div>
          <div className="m-stat-label">Total Invoiced</div>
          <div className="m-stat-figure">{formatCurrency(total)}</div>
          <div className="m-stat-sub">{invoices.length} invoice{invoices.length === 1 ? '' : 's'} on file</div>
        </div>
        <DollarSign className="h-8 w-8 text-sage" />
      </div>
    </div>
  );
}

async function InvoicesTable() {
  const invoices = await getInvoices();

  return (
    <div className="m-card">
      <div className="mb-6 flex items-center justify-between">
        <h3>Invoices</h3>
      </div>

      {invoices.length === 0 ? (
        <p className="text-ink-muted">No invoices on file yet</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b-2 border-line text-left font-semibold text-ink-muted">
                <th className="pb-3">Reference</th>
                <th className="pb-3">Status</th>
                <th className="pb-3">Amount</th>
                <th className="pb-3">Issued</th>
              </tr>
            </thead>
            <tbody>
              {invoices.map((invoice: any) => (
                <tr key={invoice.id} className="border-b border-line-soft hover:bg-sand">
                  <td className="py-3 font-medium text-ink">{invoice.ref || invoice.id}</td>
                  <td className="py-3">
                    <span className={getStatusBadgeClass(invoice.status)}>{invoice.status}</span>
                  </td>
                  <td className="py-3 text-ink-muted">{formatCurrency(invoice.amount)}</td>
                  <td className="py-3 text-ink-muted">
                    {invoice.issued ? new Date(invoice.issued).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : 'Unknown'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default function CommercialsPage() {
  return (
    <div className="space-y-8 p-8">
      <div>
        <h1>Commercials</h1>
        <p className="mt-2 text-ink-muted">Invoices and commercial activity for your account</p>
      </div>

      <Suspense fallback={<div className="m-card m-skeleton h-32" />}>
        <CommercialsSummary />
      </Suspense>

      <Suspense fallback={<div className="m-card m-skeleton h-64" />}>
        <InvoicesTable />
      </Suspense>
    </div>
  );
}
```

### `utils/supabase/client.ts`

```ts
import { createBrowserClient } from "@supabase/ssr";

let client: ReturnType<typeof createBrowserClient> | undefined;

export function createClient() {
  if (!client) {
    client = createBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );
  }

  return client;
}
```

### `utils/supabase/server.ts`

```ts
import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet: Array<{ name: string; value: string; options: CookieOptions }>) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set(name, value, options);
            });
          } catch (error) {
            // Ignore
          }
        },
      },
    }
  );
}
```

### `utils/supabase/middleware.ts`

```ts
import { type CookieOptions, createServerClient } from "@supabase/ssr";
import { type NextRequest, NextResponse } from "next/server";

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet: Array<{ name: string; value: string; options: CookieOptions }>) {
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options);
          });
        },
      },
    }
  );

  const {
    data: { session },
  } = await supabase.auth.getSession();

  return { response, session };
}
```

### `.env.local` (create this yourself — do not commit real keys)

```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```
