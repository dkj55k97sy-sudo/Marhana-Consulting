import Link from "next/link";

const SERVICES = [
  { slug: "bid-fit-score", name: "Bid Fit Score" },
  { slug: "bid-readiness-assessment", name: "Bid Readiness Assessment" },
  { slug: "tender-and-pqq-writing", name: "Tender and PQQ Writing" },
  { slug: "social-value-statements", name: "Social Value Statements" },
  { slug: "evidence-bank-development", name: "Evidence Bank Development" },
  { slug: "framework-applications", name: "Framework Applications" },
];

const COMPANY = [
  { href: "/how-we-work", name: "How We Work" },
  { href: "/pricing", name: "Pricing" },
  { href: "/credentials", name: "Credentials" },
  { href: "/policies", name: "Policies" },
  { href: "/contact", name: "Contact" },
];

export default function Footer() {
  return (
    <footer className="bg-[#0A192F] text-slate-300">
      <div className="mx-auto max-w-6xl px-6 py-16">
        <div className="grid gap-12 md:grid-cols-[1.4fr_1fr_1fr]">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-[#F8FAFC]">
              Marhana &amp; Co Consulting Ltd
            </p>
            <p className="mt-4 max-w-sm text-sm leading-relaxed text-slate-400">
              Public-sector bid and tender consultancy for SMEs. Fixed fee per
              deliverable, quoted before work starts. No success fee, no
              commission, no percentage of contract value.
            </p>
          </div>

          <nav aria-label="Services">
            <h2 className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
              Services
            </h2>
            <ul className="mt-5 space-y-3 text-sm">
              {SERVICES.map((s) => (
                <li key={s.slug}>
                  <Link
                    href={`/services/${s.slug}`}
                    className="text-slate-300 transition-colors hover:text-white"
                  >
                    {s.name}
                  </Link>
                </li>
              ))}
              <li>
                <Link
                  href="/services"
                  className="text-[#F8FAFC] underline underline-offset-4 hover:text-white"
                >
                  All 14 service lines
                </Link>
              </li>
            </ul>
          </nav>

          <nav aria-label="Company">
            <h2 className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
              Company
            </h2>
            <ul className="mt-5 space-y-3 text-sm">
              {COMPANY.map((c) => (
                <li key={c.href}>
                  <Link
                    href={c.href}
                    className="text-slate-300 transition-colors hover:text-white"
                  >
                    {c.name}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>
        </div>

        {/* Statutory disclosures — Companies Act 2006 s.82 and the Company, LLP
            and Business (Names and Trading Disclosures) Regulations 2015 */}
        <div className="mt-14 border-t border-white/10 pt-8">
          <dl className="grid gap-x-10 gap-y-6 text-sm sm:grid-cols-2 lg:grid-cols-4">
            <div>
              <dt className="text-xs uppercase tracking-[0.14em] text-slate-500">
                Registered name
              </dt>
              <dd className="mt-1 text-slate-300">
                Marhana &amp; Co Consulting Ltd
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-[0.14em] text-slate-500">
                Registered in England and Wales
              </dt>
              <dd className="mt-1 text-slate-300">
                Company number {process.env.NEXT_PUBLIC_COMPANY_NUMBER ?? "[COMPANY NUMBER]"}
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-[0.14em] text-slate-500">
                Registered office
              </dt>
              <dd className="mt-1 text-slate-300">
                {process.env.NEXT_PUBLIC_REGISTERED_OFFICE ??
                  "[REGISTERED OFFICE ADDRESS], Greater London, United Kingdom"}
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-[0.14em] text-slate-500">
                VAT
              </dt>
              <dd className="mt-1 text-slate-300">
                Not VAT registered — turnover is below the statutory
                registration threshold. No VAT is charged.
              </dd>
            </div>
          </dl>
        </div>

        <div className="mt-10 flex flex-col gap-4 border-t border-white/10 pt-8 text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between">
          <p>
            &copy; {new Date().getFullYear()} Marhana &amp; Co Consulting Ltd.
            All rights reserved.
          </p>
          <div className="flex flex-wrap gap-x-6 gap-y-2">
            <Link href="/privacy" className="hover:text-slate-300">
              Privacy Notice
            </Link>
            <Link href="/terms" className="hover:text-slate-300">
              Website and Portal Terms
            </Link>
            <Link href="/cookies" className="hover:text-slate-300">
              Cookies
            </Link>
          </div>
        </div>

        <p className="mt-8 max-w-3xl text-xs leading-relaxed text-slate-600">
          Marhana &amp; Co Consulting Ltd provides bid and tender consultancy.
          Nothing on this website is legal advice, and no information published
          here should be relied upon as an assurance of any procurement outcome.
          Evaluation is a matter for the contracting authority.
        </p>
      </div>
    </footer>
  );
}
