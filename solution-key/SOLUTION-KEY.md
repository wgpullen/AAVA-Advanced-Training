# 🔑 Capstone Solution Key — INSTRUCTOR ONLY

> Do not distribute to students before the debrief. This is the reference decomposition, the exact
> evidence-backed ACTIVE/DEAD analysis, the artifact specs, and the scoring rubric. It is derived
> from the production-validated **COBOL Legacy Modernization Pipeline** (realm 32, Test Run #2,
> 2026-05-13) — an 8-agent workflow that has run end-to-end successfully.

---

## 1. The reference decomposition (8 agents, one task each)

| # | Agent | One job | Tools | KB | Model / Preset |
|---|---|---|---|---|---|
| 1 | **COBOL Source Parser & Dependency Mapper** | Static parse: programs, paragraphs, copybooks, CALL/COPY/file I/O, data structures | Current DateTime, AzureBlobRecursiveReader, AzureBlobWriter | cobol-modernization-standards | gpt-4o · Deterministic |
| 2 | **Runtime Log Analyzer** ⭐ | Cross-ref paragraphs vs JCL + CICS logs → **ACTIVE vs DEAD** with confidence + reason | AzureBlobRecursiveReader, AzureBlobReader, AzureBlobWriter | cobol-modernization-standards | gpt-4o · Deterministic |
| 3 | Technical Documentation Creator | Modern tech docs for **ACTIVE code only** | AzureBlobReader, AzureBlobWriter | same | gpt-4o · Balanced |
| 4 | User Story Creator | Dev-ready stories for **ACTIVE functionality only** | AzureBlobReader, AzureBlobWriter | same | gpt-4o · Balanced |
| 5 | HLD & LLD Creator | Spring Boot target design (active components only) | AzureBlobReader, AzureBlobWriter | same | gpt-4o · Deterministic |
| 6 | Spring Boot Code Generator | Compilation-ready Java for **ACTIVE business logic only** | AzureBlobReader, AzureBlobWriter | same | gpt-4o · Deterministic |
| 7 | JUnit Test Generator | JUnit 5 + Mockito coverage of migrated logic | AzureBlobReader, AzureBlobWriter | same | gpt-4o · Deterministic |
| 8 | Executive Report Generator | C-suite HTML report: scope, savings %, active map, ROI | AzureBlobRecursiveReader, AzureBlobWriter | same | gpt-4o · Balanced |

**Why Agent 2 is the whole point of the exercise:** without a dedicated runtime-evidence step, you
cannot defensibly retire code — and you will silently over-migrate `CUSTMGMT` (see §3). Every
downstream agent (3–8) is explicitly scoped to **ACTIVE code only** — that scoping is what converts
Agent 2's intelligence into real cost savings.

**Shared tools — reuse, do NOT recreate** (realm 32): `Current DateTime Tool` (4525),
`AzureBlobReaderTool` (4521), `AzureBlobWriterTool` (5964), and the recursive reader
(`AzureBlobRecursiveReader`, id 3412 — ⚠️ confirm the EXACT registered tool name before wiring it,
Commandment #3; the agent instructions reference `AzureBlobRecursiveReaderTool`).

---

## 2. The data-flow contract

- Agent 1 generates `azure_parent_folder` (YYYY_MM_DD_HH_MM_SS) and threads it to all 8 (Commandment #2).
- Pre-staged inputs live in container root: `source/` and `logs/`. Agent outputs land in
  `{azure_parent_folder}/agentN_*.md` (and `agent8_executive_report.html`).
- Every agent ends by writing its artifact via `AzureBlobWriterTool` (param is `content`,
  Commandment #4) and emitting the SAS URL for the next agent.

---

## 3. ⭐ The correct ACTIVE / DEAD analysis (this is the answer key)

### CUSTMGMT.cbl — 16 paragraphs → **12 ACTIVE, 4 DEAD**

| DEAD paragraph | Exec count (2024) | Last run | Why dead |
|---|---|---|---|
| `7000-ARCHIVE-CUSTOMERS` | 0 | 2019-06-15 | Replaced by DB2 archival (2020) |
| `7100-WRITE-ARCHIVE` | 0 | 2019-06-15 | Child of 7000 |
| `8000-PURGE-INACTIVE` | 0 | 2018-12-01 | Blocked by compliance / data-retention (2019) |
| `9000-MIGRATE-TO-NEW-SYSTEM` | 0 | NEVER | Cancelled 2017 migration; stub only |

> 🪤 **THE TRAP:** these four paragraphs are **statically reachable** — `0000-MAIN-CONTROL`'s
> `EVALUATE` dispatches to them on function codes `FC-ARCHIVE` / `FC-PURGE` / `FC-MIGRATE`. A
> static-only analyzer (Agent 1 alone) sees live `PERFORM` targets and will mark them **keep**.
> Only the **runtime logs** expose the truth: CICS transactions `CARC`, `CPRG`, `CMIG` all show
> **0 executions in 2024** and last-run dates 5–7 years stale. **A team without a Runtime Log
> Analyzer step will migrate this dead code.** That is the #1 failure to look for.

### ACCTPROC.cbl — 16 paragraphs → **11 ACTIVE, 5 DEAD**

| DEAD paragraph | Exec count (2024) | Last run | Why dead |
|---|---|---|---|
| `5000-CALCULATE-MONTHLY-FEES` | 0 | 2021-03-31 | Replaced by real-time `FEECALC` engine (2021) |
| `5100-APPLY-LOW-BALANCE-FEE` | 0 | 2021-03-31 | Child of 5000 |
| `5200-APPLY-EXCESS-TRAN-FEE` | 0 | 2021-03-31 | Child of 5000 |
| `6000-GENERATE-PAPER-STATEMENTS` | 0 | 2020-06-30 | Replaced by e-statements (2020) |
| `7000-Y2K-DATE-CHECK` | 0 | 2000-01-15 | Obsolete since Y2K |

> Contrast: ACCTPROC's dead paragraphs are **statically UNREACHABLE** — `0000-MAIN-CONTROL` only
> `PERFORM`s `1000/2000/3000/4000/9000`. A good static analyzer (Agent 1) flags 5000/6000/7000 as
> **orphan paragraphs** on its own. The runtime logs then *confirm* the call. **Teaching point:
> static and runtime analysis are complementary — you need BOTH, and they catch different things.**

### Combined scorecard (what the executive report must show)

| Metric | Value |
|---|---|
| Total programs | 2 |
| Total paragraphs | 32 |
| **ACTIVE** | **23 (71.9%)** |
| **DEAD** | **9 (28.1%)** |
| Dead procedural lines | ~140 of 485 (**28.9%**) |
| Est. Java NOT written | ~400–600 lines |
| **Scope reduction / savings** | **~28.9%** vs a 1-for-1 rewrite |

---

## 4. Expected COBOL → Spring Boot target (active logic only)

From the KB mapping rules (`cobol-modernization-standards`):

- `CUSTMGMT` → `CustomerService` (@Service); active functions → `add/update/delete(soft)/inquiry/report`
  exposed via `@RestController` (CICS trans CUST/CINQ/CADD/CUPD/CDEL/CRPT).
- `ACCTPROC` → `AccountBatchService` + `@Scheduled` nightly job; active paths → process transactions,
  accrue daily interest, generate (electronic) statements.
- `CUSTREC`/`ACCTREC` copybooks → JPA `@Entity`/DTO classes; `COMP-3` money fields → `BigDecimal`.
- VSAM indexed files → Spring Data JPA repositories. `EVALUATE` → switch. `PERFORM` → method call.
- Stack: Java 21, Spring Boot 3.5, Jakarta annotations, JUnit 5 + Mockito, Maven.
- **Explicitly NOT built:** archive, purge, migrate stub, monthly-fee batch, paper statements, Y2K check.

---

## 5. Scoring rubric (compare each team against this)

| # | Criterion | Pass = | Weight |
|---|---|---|---|
| 1 | Built a dedicated **runtime-log analysis** step (Agent 2 equivalent) | Yes/No | 🔴 critical |
| 2 | Correctly identified **9 dead paragraphs** with **log evidence + reason** | ≥ 8/9 | 🔴 critical |
| 3 | Did **not** modernize dead code (Agents 3–8 scoped to ACTIVE only) | Yes/No | 🔴 critical |
| 4 | Reported the **~28.9% scope reduction** in the exec report | Yes/No | 🟠 |
| 5 | Reused shared Azure tools (didn't recreate) | Yes/No | 🟠 |
| 6 | Threaded `azure_parent_folder` through all agents (Commandment #2) | Yes/No | 🟠 |
| 7 | Used STEP / "DO NOT PROCEED" blocking language (no synthetic-data failures) | Yes/No | 🟠 |
| 8 | Tested agents (`execute_single_agent`) **before** approving; approved in order | Yes/No | 🟢 |
| 9 | Spring Boot output uses BigDecimal for money, JPA, @RestController | Yes/No | 🟢 |
| 10 | Ended with a board-ready executive HTML report | Yes/No | 🟢 |

**The headline question for the debrief:** *"How many paragraphs did you retire, and what's your
evidence?"* The right answer is **9 dead / 23 active**, evidenced by 0-execution counts and stale
last-run dates in the JCL + CICS logs — **with special credit to any team that caught that
`CUSTMGMT`'s dead code is statically reachable and required the runtime logs to expose.**

---

## 6. Common failure modes (what you'll see teams do)

- **Skip Agent 2** → migrate all 32 paragraphs → 28.9% wasted scope. (Most common.)
- **Static-only** → catch ACCTPROC's orphans but keep CUSTMGMT's archive/purge/migrate. (The trap.)
- **Recreate the Azure tools** → wastes time; violates reuse-over-create.
- **Synthetic data** → agent "summarizes" logs it never read (Commandment #7); fix with blocking language.
- **Approve before testing** → can't defend output to the board. Enforce test → validate → approve.

> Reference artifacts: full agent specs in `reference-agents/`; live workflow
> `17814 Ramya COBOL Legacy Modernization Pipeline Clone` (APPROVED, realm 32).
