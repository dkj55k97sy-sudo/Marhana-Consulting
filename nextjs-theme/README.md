# Making your Next.js portal match the website

Two files and a handful of class-name swaps. No restructuring — your working
code stays as it is.

---

## 0. Logos

This folder contains `public/logo-lockup-t.png` and `public/logo-mark-t.png`.
Copy both into your project's own `public/` directory. The lockup is for the
login page, the mark for the sidebar.

## 1. Replace your global stylesheet

Copy `globals.css` from this folder over `app/globals.css`.

That alone fixes the fonts, the background, the heading scale and the link
colours across every page.

## 2. Add the palette to Tailwind

`tailwind.config.ts`:

```ts
export default {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        cream:    '#F5F1E8',
        sand:     '#EFE9DC',
        line:     '#E9E1D0',
        teal:     '#113C39',
        'teal-deep': '#0C2C2A',
        'teal-mid':  '#2E6A60',
        sage:     '#9CBDB2',
        clay:     '#B4694F',
        ink:      '#1E2422',
        'ink-muted': '#5A625E',
        'ink-faint': '#8A8375',
      },
      fontFamily: {
        serif: ['Cormorant Garamond', 'Garamond', 'serif'],
        sans:  ['Libre Franklin', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
      boxShadow: {
        lift:  '0 20px 40px rgba(17, 60, 57, 0.08)',
        hover: '0 28px 56px -28px rgba(17, 60, 57, 0.30)',
      },
    },
  },
};
```

## 3. Swap class names

Find whatever the other build generated and replace it. The left column is
typical AI-generated Tailwind; the right is ours.

| Instead of | Use |
|---|---|
| `bg-white rounded-lg shadow-md p-6 border` | `m-card` |
| `bg-white rounded-lg shadow-md hover:shadow-lg` | `m-card m-card-hover` |
| `bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700` | `m-btn` |
| `border px-3 py-2 rounded` (secondary button) | `m-btn-quiet` |
| `w-full border rounded px-3 py-2` (input) | `m-input` |
| `block text-sm font-medium mb-1` (label) | `m-label` |
| `bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs` | `m-badge m-badge-progress` |
| `bg-yellow-100 text-yellow-800 …` | `m-badge m-badge-action` |
| `bg-gray-800 text-white …` | `m-badge m-badge-done` |
| `bg-gray-200 rounded-full h-2` | `m-progress` |
| `bg-blue-600 h-2 rounded-full` | `m-progress-fill` |
| `bg-gray-900 text-white w-64 …` (sidebar) | `m-sidebar` |
| sidebar link | `m-nav-item` / `m-nav-item-active` |
| `sticky top-0 bg-white border-b` | `m-header` |
| `animate-pulse bg-gray-200` | `m-skeleton` |

## 4. Four details that make it look like ours

These are the things generic templates miss.

**Figures are serif, not bold sans.** Every number on the dashboard:

```tsx
<div className="m-stat-label">Active bids</div>
<div className="m-stat-figure">{bids.length}</div>
<div className="m-stat-sub">{drafting} in drafting · {review} in review</div>
```

**The active sidebar item has a sage bar inset on its left edge** — not a
filled pill. That's `m-nav-item-active`, already in the CSS.

**Progress rings are conic gradients, not SVG circles:**

```tsx
<div
  className="w-[158px] h-[158px] rounded-full grid place-items-center mx-auto"
  style={{ background:
    `conic-gradient(#9CBDB2 0 ${pct}%, rgba(247,243,234,0.14) ${pct}% 100%)` }}
>
  <div className="w-[118px] h-[118px] rounded-full bg-teal grid place-items-center">
    <span className="font-serif text-[44px] leading-none text-[#F7F3EA]">
      {pct}%
    </span>
  </div>
</div>
```

**Colour carries meaning, not decoration.** Teal and sage for normal state,
clay *only* for something needing the client's action. No blues, no greens,
no reds anywhere.

## 5. Icons

Lucide is fine. Set them to `strokeWidth={1.6}` and `size={17}` in the
sidebar — the default 2px stroke reads too heavy against Cormorant.

## 6. Login page

Split screen. Left is `bg-teal-deep` with the full logo lockup
(`logo-lockup-t.png` from this project — copy it into `public/`), a serif
headline, and a line of body copy. Right is the form on cream, max-width
380px, centred. `m-label` / `m-input` / `m-btn` do the rest.

---

## One thing to check

Your build likely uses `#faf9f5` for the background. Ours is `#F5F1E8` —
slightly warmer and a shade deeper. Small difference, but side by side the
lighter one looks washed out against the teal. Worth changing.
