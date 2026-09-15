"use client";

import Link from "next/link";
import { useMemo, useState } from "react";

/**
 * BidViabilityCheck
 * Free five-question self-check. Mirrors the criteria the paid Bid Fit Score
 * (£150–£350) assesses formally: fit against published qualification
 * requirements, disqualifying checks, evidence, and scoring weight.
 *
 * Nothing here is stored or transmitted — all state is local.
 */

type Option = { label: string; hint?: string; score: number; blocker?: boolean };
type Question = { id: string; title: string; context: string; options: Option[] };

const QUESTIONS: Question[] = [
  {
    id: "turnover",
    title: "How does the annual contract value compare with your annual turnover?",
    context:
      "Authorities commonly apply a financial standing test and will not award a contract worth a disproportionate share of a supplier's turnover.",
    options: [
      { label: "Contract is under a quarter of our turnover", score: 2 },
      { label: "Between a quarter and half of our turnover", score: 2 },
      { label: "Between half and equal to our turnover", score: 1, hint: "Expect a financial standing challenge. Have a parent guarantee or funding position ready." },
      { label: "Larger than our annual turnover", score: 0, blocker: true, hint: "Usually a hard fail unless you bid as part of a consortium." },
      { label: "We do not know the contract value yet", score: 0 },
    ],
  },
  {
    id: "accreditations",
    title: "Do you already hold every accreditation stated as mandatory?",
    context:
      "A mandatory accreditation absent at the submission deadline is a disqualification, not a lost mark.",
    options: [
      { label: "Yes, all held and in date", score: 2 },
      { label: "All held, but one expires before contract start", score: 1, hint: "Renew before you submit and evidence the renewal in the response." },
      { label: "One or more missing, achievable before the deadline", score: 1 },
      { label: "One or more missing and not achievable in time", score: 0, blocker: true },
      { label: "We have not read the qualification requirements yet", score: 0 },
    ],
  },
  {
    id: "evidence",
    title: "Can you evidence comparable contracts of similar scope and value?",
    context:
      "Selection stage normally requires up to three relevant contract examples, with named clients, values and dates.",
    options: [
      { label: "Three or more, documented with values and references", score: 2 },
      { label: "Two or three, but not written up", score: 1, hint: "Allow time for evidence capture before drafting." },
      { label: "One only, or all in a different sector", score: 1 },
      { label: "None in comparable scope or value", score: 0, blocker: true },
      { label: "We hold the work but cannot name the clients", score: 1 },
    ],
  },
  {
    id: "socialvalue",
    title: "Can you make and measure specific social value commitments?",
    context:
      "Social value carries a minimum 10% weighting in central government procurement and frequently more in local authority contracts. Unmeasurable commitments score poorly.",
    options: [
      { label: "Yes — specific commitments with named owners and measures", score: 2 },
      { label: "We deliver social value but do not measure it", score: 1 },
      { label: "We could commit, but nothing is in place today", score: 1 },
      { label: "No capacity to commit beyond the contract itself", score: 0 },
      { label: "We do not know what is being asked for", score: 0 },
    ],
  },
  {
    id: "weighting",
    title: "What is the quality-to-price evaluation split?",
    context:
      "A price-dominant evaluation rewards cost base, not writing. A quality-weighted evaluation is where a well-evidenced response changes the outcome.",
    options: [
      { label: "Quality 60% or more", score: 2 },
      { label: "Roughly even split", score: 2 },
      { label: "Price 60–80%", score: 1, hint: "Win probability turns on your cost base more than your narrative." },
      { label: "Price above 80%, or lowest price wins", score: 0, hint: "Only bid if you are confident you are among the cheapest compliant suppliers." },
      { label: "Not stated in the documents we have", score: 0 },
    ],
  },
];

const MAX = QUESTIONS.length * 2;

type Band = {
  key: "green" | "amber" | "red";
  label: string;
  headline: string;
  body: string;
  ring: string;
  text: string;
  chip: string;
};

const BANDS: Record<Band["key"], Band> = {
  green: {
    key: "green",
    label: "Green",
    headline: "Worth pursuing on the information you have given",
    body: "Nothing in your answers disqualifies you and the evaluation rewards quality. The remaining risk is drafting and evidence, not eligibility. Confirm against the published documents before you commit resource.",
    ring: "#059669",
    text: "text-[#059669]",
    chip: "bg-[#059669]/10 text-[#047857] ring-1 ring-inset ring-[#059669]/30",
  },
  amber: {
    key: "amber",
    label: "Amber",
    headline: "Bid only with the gaps closed first",
    body: "There are gaps that will cost marks or create qualification risk. They are usually closable, but not in the last week before a deadline. Sequence the remedial work before you start drafting.",
    ring: "#D97706",
    text: "text-[#D97706]",
    chip: "bg-[#D97706]/10 text-[#B45309] ring-1 ring-inset ring-[#D97706]/30",
  },
  red: {
    key: "red",
    label: "Red",
    headline: "The cost of bidding is unlikely to be recovered",
    body: "On your answers there is at least one issue that typically ends in disqualification or a low score regardless of how well the response is written. The better decision is usually to close the gap and target the next comparable opportunity.",
    ring: "#B91C1C",
    text: "text-[#B91C1C]",
    chip: "bg-[#B91C1C]/10 text-[#991B1B] ring-1 ring-inset ring-[#B91C1C]/30",
  },
};

function bandFor(score: number, blockers: number): Band {
  if (blockers > 0 || score <= 4) return BANDS.red;
  if (score <= 7) return BANDS.amber;
  return BANDS.green;
}

function Gauge({ value, band }: { value: number; band: Band }) {
  const pct = Math.max(0, Math.min(1, value / MAX));
  const r = 64;
  const circumference = Math.PI * r; // semicircle
  return (
    <svg viewBox="0 0 160 96" className="h-28 w-48" role="img" aria-label={`Readiness ${band.label}, ${value} of ${MAX}`}>
      <path d="M16 84 A64 64 0 0 1 144 84" fill="none" stroke="#E2E8F0" strokeWidth="14" strokeLinecap="round" />
      <path
        d="M16 84 A64 64 0 0 1 144 84"
        fill="none"
        stroke={band.ring}
        strokeWidth="14"
        strokeLinecap="round"
        strokeDasharray={`${circumference * pct} ${circumference}`}
        className="transition-[stroke-dasharray] duration-700 ease-out"
      />
      <text x="80" y="76" textAnchor="middle" className="fill-[#0A192F] text-[26px] font-semibold">
        {value}
        <tspan className="fill-slate-400 text-[14px]">/{MAX}</tspan>
      </text>
    </svg>
  );
}

export default function BidViabilityCheck() {
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<(number | null)[]>(() => QUESTIONS.map(() => null));
  const [done, setDone] = useState(false);

  const { score, blockers, flags } = useMemo(() => {
    let s = 0;
    let b = 0;
    const f: string[] = [];
    answers.forEach((a, i) => {
      if (a === null) return;
      const opt = QUESTIONS[i].options[a];
      s += opt.score;
      if (opt.blocker) b += 1;
      if (opt.hint) f.push(opt.hint);
    });
    return { score: s, blockers: b, flags: f };
  }, [answers]);

  const band = bandFor(score, blockers);
  const q = QUESTIONS[step];
  const selected = answers[step];

  function choose(i: number) {
    setAnswers((prev) => {
      const next = [...prev];
      next[step] = i;
      return next;
    });
  }

  function next() {
    if (step < QUESTIONS.length - 1) setStep(step + 1);
    else setDone(true);
  }

  function reset() {
    setAnswers(QUESTIONS.map(() => null));
    setStep(0);
    setDone(false);
  }

  return (
    <section className="mx-auto w-full max-w-3xl" aria-labelledby="bid-check-heading">
      <div className="overflow-hidden rounded-lg bg-white ring-1 ring-slate-200">
        <header className="border-b border-slate-200 px-6 py-6 sm:px-8">
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#059669]">
            Free self-check
          </p>
          <h2 id="bid-check-heading" className="mt-2 text-2xl font-semibold tracking-tight text-[#0A192F]">
            Should you bid?
          </h2>
          <p className="mt-2 text-sm leading-relaxed text-slate-600">
            Five questions, about a minute. Your answers stay in your browser —
            nothing is sent to us and nothing is stored.
          </p>
        </header>

        {!done ? (
          <div className="px-6 py-8 sm:px-8">
            <div className="flex items-center gap-3" aria-hidden="true">
              {QUESTIONS.map((item, i) => (
                <span
                  key={item.id}
                  className={`h-1 flex-1 rounded-full transition-colors ${
                    i < step ? "bg-[#059669]" : i === step ? "bg-[#0A192F]" : "bg-slate-200"
                  }`}
                />
              ))}
            </div>
            <p className="mt-4 text-xs font-medium uppercase tracking-[0.14em] text-slate-500">
              Question {step + 1} of {QUESTIONS.length}
            </p>

            <h3 className="mt-3 text-xl font-semibold leading-snug text-[#0A192F]">
              {q.title}
            </h3>
            <p className="mt-2 text-sm leading-relaxed text-slate-600">{q.context}</p>

            <fieldset className="mt-6">
              <legend className="sr-only">{q.title}</legend>
              <div className="flex flex-col gap-2">
                {q.options.map((opt, i) => {
                  const active = selected === i;
                  return (
                    <button
                      key={opt.label}
                      type="button"
                      aria-pressed={active}
                      onClick={() => choose(i)}
                      className={`rounded-md border px-4 py-3 text-left text-sm transition-colors ${
                        active
                          ? "border-[#0A192F] bg-[#0A192F] text-white"
                          : "border-slate-200 bg-[#F8FAFC] text-[#334155] hover:border-slate-400"
                      }`}
                    >
                      {opt.label}
                    </button>
                  );
                })}
              </div>
            </fieldset>

            <div className="mt-8 flex items-center justify-between gap-4">
              <button
                type="button"
                onClick={() => setStep(Math.max(0, step - 1))}
                disabled={step === 0}
                className="text-sm font-medium text-slate-500 disabled:opacity-40"
              >
                Back
              </button>
              <button
                type="button"
                onClick={next}
                disabled={selected === null}
                className="rounded-md bg-[#0A192F] px-6 py-3 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-30"
              >
                {step === QUESTIONS.length - 1 ? "See result" : "Next"}
              </button>
            </div>
          </div>
        ) : (
          <div className="px-6 py-8 sm:px-8">
            <div className="flex flex-col items-start gap-6 sm:flex-row sm:items-center">
              <Gauge value={score} band={band} />
              <div>
                <span className={`inline-flex rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] ${band.chip}`}>
                  {band.label}
                </span>
                <h3 className="mt-3 text-xl font-semibold leading-snug text-[#0A192F]">
                  {band.headline}
                </h3>
              </div>
            </div>

            <p className="mt-5 text-sm leading-relaxed text-slate-600">{band.body}</p>

            {flags.length > 0 && (
              <div className="mt-6 rounded-md bg-[#F8FAFC] p-5 ring-1 ring-slate-200">
                <h4 className="text-xs font-semibold uppercase tracking-[0.14em] text-slate-500">
                  What your answers flag
                </h4>
                <ul className="mt-3 space-y-2">
                  {flags.map((f) => (
                    <li key={f} className="flex gap-3 text-sm leading-relaxed text-[#334155]">
                      <span aria-hidden="true" className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-[#D97706]" />
                      {f}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            <div className="mt-8 rounded-md border border-[#0A192F] bg-[#0A192F] p-6 text-white">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#F8FAFC]/70">
                Verify this result
              </p>
              <h4 className="mt-2 text-lg font-semibold">
                Bid Fit Score — £150 to £350, fixed fee
              </h4>
              <p className="mt-3 text-sm leading-relaxed text-slate-300">
                A written scorecard against the actual published documents:
                numerical fit score, disqualifying checks, the strengths to
                emphasise, the material gaps to close, clarifications to raise,
                the cost of bidding, and a bid or no-bid recommendation. One
                round of written questions on the scorecard is included.
              </p>
              <div className="mt-5 flex flex-wrap gap-3">
                <Link
                  href="/services/bid-fit-score"
                  className="rounded-md bg-white px-5 py-3 text-sm font-semibold text-[#0A192F] transition-opacity hover:opacity-90"
                >
                  Order a Bid Fit Score
                </Link>
                <Link
                  href="/contact"
                  className="rounded-md px-5 py-3 text-sm font-semibold text-white ring-1 ring-inset ring-white/30 transition-colors hover:bg-white/10"
                >
                  Ask a question first
                </Link>
              </div>
              <p className="mt-4 text-xs leading-relaxed text-slate-400">
                Our fee is the same whether you win or lose. We do not price on
                outcome and we take no commission or percentage of contract
                value.
              </p>
            </div>

            <button
              type="button"
              onClick={reset}
              className="mt-6 text-sm font-medium text-slate-500 underline underline-offset-4 hover:text-[#0A192F]"
            >
              Start again
            </button>
          </div>
        )}
      </div>

      <p className="mt-4 text-xs leading-relaxed text-slate-500">
        This self-check is an indicative guide based on the answers you give. It
        is not an assessment of any specific procurement and is not advice. A go
        result is not an assurance of success and a no-go result is not an
        assurance of failure.
      </p>
    </section>
  );
}
