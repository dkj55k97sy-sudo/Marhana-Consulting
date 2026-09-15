"use client";

import { useState } from "react";

/**
 * ContactForm — conflict-safe enquiry form.
 *
 * The conflict check (T13 Client Onboarding and Conflict Check) is run before
 * an engagement is accepted. This form therefore deliberately does not collect
 * authority names, tender references or portal links: taking them before the
 * check is run can itself create the conflict.
 *
 * Wire `action` to your own route handler / Supabase insert.
 */

const SECTORS = [
  "Construction and civil engineering",
  "Facilities management",
  "Healthcare and clinical services",
  "Social care and supported housing",
  "Education and training",
  "Professional and business services",
  "Transport and logistics",
  "Waste, environment and grounds",
  "IT and digital",
  "Other",
];

const TURNOVER_BANDS = [
  "Under £250,000",
  "£250,000 – £1m",
  "£1m – £5m",
  "£5m – £10m",
  "Over £10m",
  "Prefer not to say",
];

const INTERESTS = [
  "Bid Fit Score",
  "Bid Readiness Assessment",
  "Tender and PQQ writing",
  "Bid review and rewrite",
  "Social value statements",
  "Evidence Bank development",
  "Framework applications",
  "Monthly retainer",
  "Not sure yet",
];

type Status = "idle" | "submitting" | "sent" | "error";

export default function ContactForm() {
  const [status, setStatus] = useState<Status>("idle");

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus("submitting");
    const data = Object.fromEntries(new FormData(e.currentTarget).entries());
    try {
      const res = await fetch("/api/enquiry", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      if (!res.ok) throw new Error("Request failed");
      setStatus("sent");
    } catch {
      setStatus("error");
    }
  }

  if (status === "sent") {
    return (
      <div className="mx-auto w-full max-w-2xl rounded-lg bg-white p-8 ring-1 ring-slate-200">
        <span className="inline-flex rounded-full bg-[#059669]/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] text-[#047857] ring-1 ring-inset ring-[#059669]/30">
          Enquiry received
        </span>
        <h2 className="mt-4 text-2xl font-semibold tracking-tight text-[#0A192F]">
          Thank you. We will reply within one working day.
        </h2>
        <p className="mt-4 text-sm leading-relaxed text-slate-600">
          Before any engagement is accepted we run a conflict check against our
          current and recent client list for the same opportunity. If the check
          is clear we will send a fixed-fee quotation on our Proposal and Fee
          Quotation form, which states what is included and what is not. No work
          starts until you accept it in writing.
        </p>
      </div>
    );
  }

  const label = "block text-sm font-medium text-[#0A192F]";
  const field =
    "mt-2 w-full rounded-md border border-slate-300 bg-white px-4 py-3 text-sm text-[#334155] outline-none transition-colors placeholder:text-slate-400 focus:border-[#0A192F] focus:ring-2 focus:ring-[#0A192F]/15";

  return (
    <form
      onSubmit={onSubmit}
      className="mx-auto w-full max-w-2xl rounded-lg bg-white p-6 ring-1 ring-slate-200 sm:p-8"
      noValidate={false}
    >
      <h2 className="text-2xl font-semibold tracking-tight text-[#0A192F]">
        Make an enquiry
      </h2>
      <p className="mt-2 text-sm leading-relaxed text-slate-600">
        Tell us the shape of the problem. We will come back with whether we can
        help, which service fits, and an indicative fee band.
      </p>

      <div
        role="note"
        className="mt-6 rounded-md border-l-2 border-[#D97706] bg-[#D97706]/5 p-4"
      >
        <p className="text-xs font-semibold uppercase tracking-[0.14em] text-[#B45309]">
          Before you write
        </p>
        <p className="mt-2 text-sm leading-relaxed text-[#334155]">
          To protect client confidentiality and clear conflict checks, do not
          paste live tender links or authority names into this form.
        </p>
        <p className="mt-2 text-sm leading-relaxed text-slate-600">
          A general description is enough at this stage. Once the conflict check
          is clear we will ask for the detail through a secure channel.
        </p>
      </div>

      <div className="mt-8 grid gap-6 sm:grid-cols-2">
        <div>
          <label className={label} htmlFor="name">
            Your name
          </label>
          <input id="name" name="name" type="text" required autoComplete="name" className={field} />
        </div>
        <div>
          <label className={label} htmlFor="email">
            Work email
          </label>
          <input id="email" name="email" type="email" required autoComplete="email" className={field} />
        </div>
        <div>
          <label className={label} htmlFor="company">
            Company
          </label>
          <input id="company" name="company" type="text" required autoComplete="organization" className={field} />
        </div>
        <div>
          <label className={label} htmlFor="phone">
            Telephone <span className="font-normal text-slate-400">(optional)</span>
          </label>
          <input id="phone" name="phone" type="tel" autoComplete="tel" className={field} />
        </div>
        <div>
          <label className={label} htmlFor="sector">
            Sector
          </label>
          <select id="sector" name="sector" required defaultValue="" className={field}>
            <option value="" disabled>
              Select a sector
            </option>
            {SECTORS.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className={label} htmlFor="turnover">
            Annual turnover band
          </label>
          <select id="turnover" name="turnover" required defaultValue="" className={field}>
            <option value="" disabled>
              Select a band
            </option>
            {TURNOVER_BANDS.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="mt-6">
        <label className={label} htmlFor="interest">
          What you think you need
        </label>
        <select id="interest" name="interest" defaultValue="Not sure yet" className={field}>
          {INTERESTS.map((i) => (
            <option key={i} value={i}>
              {i}
            </option>
          ))}
        </select>
      </div>

      <div className="mt-6">
        <label className={label} htmlFor="enquiry">
          Rough nature of enquiry
        </label>
        <p className="mt-1 text-xs leading-relaxed text-slate-500">
          Sector, approximate contract size, the deadline pressure you are
          under, and what you have already drafted. No authority names, no
          portal links, no reference numbers.
        </p>
        <textarea
          id="enquiry"
          name="enquiry"
          rows={6}
          required
          maxLength={2000}
          placeholder="e.g. We are a 20-person FM contractor. A framework we have used before is re-tendering in about six weeks and we have never scored well on social value."
          className={field}
        />
      </div>

      <div className="mt-6 flex items-start gap-3">
        <input
          id="consent"
          name="consent"
          type="checkbox"
          required
          className="mt-1 h-4 w-4 shrink-0 rounded border-slate-300 text-[#0A192F] focus:ring-[#0A192F]/30"
        />
        <label htmlFor="consent" className="text-sm leading-relaxed text-slate-600">
          I confirm this enquiry contains no confidential contracting authority
          information, and I agree to Marhana &amp; Co Consulting Ltd processing
          these details to respond. See our{" "}
          <a href="/privacy" className="font-medium text-[#0A192F] underline underline-offset-4">
            Privacy Notice
          </a>
          .
        </label>
      </div>

      {status === "error" && (
        <p role="alert" className="mt-6 rounded-md bg-[#B91C1C]/5 p-4 text-sm text-[#991B1B]">
          Something went wrong sending this. Please email us directly and we
          will pick it up.
        </p>
      )}

      <button
        type="submit"
        disabled={status === "submitting"}
        className="mt-8 w-full rounded-md bg-[#0A192F] px-6 py-4 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:opacity-50 sm:w-auto"
      >
        {status === "submitting" ? "Sending…" : "Send enquiry"}
      </button>

      <p className="mt-5 text-xs leading-relaxed text-slate-500">
        We reply within one working day. Every engagement is quoted as a fixed
        fee for a defined deliverable before work starts — you are not billed by
        the hour and you do not receive an invoice larger than the quotation.
      </p>
    </form>
  );
}
