# Marhana website — build notes

## Delivered so far
- `components/Footer.tsx` — statutory disclosures (Companies Act 2006 s.82 / Trading Disclosures Regs 2015). Company number and registered office read from `NEXT_PUBLIC_COMPANY_NUMBER` / `NEXT_PUBLIC_REGISTERED_OFFICE` with visible placeholders as fallback.
- `components/BidViabilityCheck.tsx` — 5-step self-check, RAG gauge, funnels to the paid Bid Fit Score. Client-side only, no data leaves the browser.
- `components/ContactForm.tsx` — conflict-safe enquiry form, posts to `/api/enquiry`.

## Tailwind tokens
```js
// tailwind.config.ts → theme.extend.colors
navy:  { DEFAULT: "#0A192F", deep: "#0F2042" },
chalk: "#F8FAFC",
slate: { ink: "#334155" },
pass:  "#059669",
warn:  "#D97706",
```
Colours are currently written as arbitrary values (`bg-[#0A192F]`) so the components drop into any config; swap for tokens once the config is updated.

## Confirmed from source documents
**M7 Schedule of Fees** — 13 priced lines + retainer:

| Service | Band |
|---|---|
| Bid Fit Score | £150 – £350 |
| Bid Readiness Assessment | £250 – £500 |
| Post-tender debrief analysis | £200 – £450 |
| Bid review and rewrite | £250 – £600 |
| Tender and PQQ writing | £500 – £2,000 |
| Social value statements | £300 – £900 |
| Financial and costed business case | £300 – £800 |
| Accreditation support | £300 – £700 |
| Evidence Bank development | £800 – £2,000 |
| Framework applications | £800 – £2,500 |
| Consortium bid coordination | £900 – £2,500 |
| Contract mobilisation | £400 – £1,200 |
| Social value delivery reporting | £300 – £600 per cycle |
| Retainer | £400 – £800 / month |

Pricing principles (M7 §A): fixed fee per deliverable, written scope and exclusions, no success fee / commission / percentage of contract value, no guarantee of outcome, bands indicative.

**Insurance (broker instructions §1.2.3)** — PI recommendation £1,000,000 each and every claim with defence costs in addition and retroactive cover to commencement of trading (£2,000,000 option quoted for comparison); PL default £2,000,000; cyber £250,000; D&O £250,000; EL £5,000,000 required from first employee.

⚠ The Schedule of Fees retainer table (Section C) still carries `[TIER 1/2/3 NAME]` and `£[FEE]` placeholders. The £400–£800 figure comes from the broker instructions, not the fee schedule. Confirm the three tier names and prices before the `/pricing` page is built.

## Open items
- Company number and registered office address.
- Retainer tier names, prices and inclusion counts.
- Cyber Essentials / APMP status wording for `/credentials`.
- `/api/enquiry` route handler + Supabase table for enquiries.
