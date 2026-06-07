# Capstone Client Brief — Meridian National Bank

> **This is the raw client input for the afternoon capstone.** Treat it exactly as you would a real
> client engagement: read it, extract the 8 critical elements (Phase 1), then decompose it into a
> workflow (Phase 2). Do **not** start building artifacts until you have a decomposition on paper.

---

## The Inbound (verbatim client email)

```
From:    Eleanor Vance <evance@meridiannational.com>
To:      Ascendion Engagement Team
Subject: Mainframe modernization — Customer & Account core (URGENT, board ask)
Date:    Monday 9:14 AM

Team,

Following our QBR, the board has approved funding to get us OFF the mainframe for our
Customer & Account core. Two COBOL programs run this today:

  - CUSTMGMT  — customer CRUD, reporting (online via CICS + a few batch jobs)
  - ACCTPROC  — nightly account batch: posts transactions, accrues interest, cuts statements

We want this on Spring Boot / Java, deployable to our cloud. The previous vendor quoted us a
1-for-1 rewrite of "every line of COBOL" at $2.4M and 14 months. That felt wrong — half this
code looks like it hasn't run in years, but nobody on my team will sign off on deleting anything
because we can't PROVE what's safe to drop.

So I'm giving you everything our ops team could pull:

  1. The COBOL source for both programs (source/)
  2. The copybooks they depend on (source/copybooks/)
  3. A full year of JCL batch execution logs — 2024 production (logs/batch_jcl_execution.log)
  4. A full year of CICS transaction logs — 2024 production (logs/cics_transaction.log)

What the board wants from you, in this order:
  A. A defensible plan: what gets migrated, what gets RETIRED, and the EVIDENCE for each call.
  B. Modern technical docs + user stories for the parts we keep (our mainframe folks are retiring).
  C. A target Spring Boot design + working code + tests for the business logic worth keeping.
  D. An executive summary I can take back to the board showing scope, savings, and risk.

I do not want to pay to rebuild code that no customer or job has touched in five years. But I also
will not let you delete anything you can't justify with data. Show me your reasoning.

Clock's ticking — we present to the board in two weeks.

— Eleanor Vance, SVP Core Platforms, Meridian National Bank
```

---

## What the client handed you (the artifact inventory)

| Artifact | Path (Azure container `cobol-legacy-modernization` / GitHub `lab-artifacts/`) | What it is |
|---|---|---|
| `CUSTMGMT.cbl` | `source/CUSTMGMT.cbl` | Customer management program — online (CICS) + batch |
| `ACCTPROC.cbl` | `source/ACCTPROC.cbl` | Nightly account-processing batch program |
| `CUSTREC.cpy` | `source/copybooks/CUSTREC.cpy` | Customer record layout (copybook) |
| `ACCTREC.cpy` | `source/copybooks/ACCTREC.cpy` | Account record layout (copybook) |
| `batch_jcl_execution.log` | `logs/batch_jcl_execution.log` | 2024 production JCL batch execution log + annual paragraph exec summary |
| `cics_transaction.log` | `logs/cics_transaction.log` | 2024 production CICS transaction log (volumes by program) |

> **Two ways to feed these to your agents:**
> 1. **Azure Blob (primary):** the files are pre-staged in the `cobol-legacy-modernization`
>    container, folders `source/` and `logs/`. Use the shared `AzureBlob*` tools.
> 2. **GitHub raw (fallback, if you don't have Azure access yet):** every file is also in this
>    repo under `lab-artifacts/`. See `capstone/01-student-instructions.md` for the raw URLs and
>    how to point an agent at them.

---

## The board's success criteria (this is what you're graded on)

1. **Did you focus the modernization on the code that actually drives business value** — and can you
   prove your scoping decisions from the evidence the client provided?
2. **Did you avoid wasting effort (and the client's money)** on code that isn't earning its keep?
3. **Did you preserve the business logic that matters faithfully** in the Spring Boot target?
4. **Can Eleanor take your executive report to the board** — scope, value, and risk, on one screen?

> ⚠️ **There is a deliberate trap in this exercise.** Bring your legacy-modernization instincts:
> not every line of COBOL is worth carrying forward, and the client handed you everything you need
> to tell the difference. Make your own decomposition *before* reading `01-student-instructions.md`.
