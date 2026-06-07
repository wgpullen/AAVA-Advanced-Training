# AAVA Advanced Engineering Course

[![Audience](https://img.shields.io/badge/Audience-Ascendion%20Engineers-blue.svg)]()
[![Format](https://img.shields.io/badge/Format-1%20Day%20·%208%20Hours-informational)]()
[![Build mode](https://img.shields.io/badge/Build-MCP--driven-7B5FFF)]()
[![Capstone](https://img.shields.io/badge/Capstone-COBOL%20→%20Spring%20Boot-D97757)]()

The hands-on, **employees-only** companion to the AAVA Sales Training Lab. Where the sales lab teaches
*what AAVA is*, this course teaches Ascendion engineers to **take a raw client problem and ship a
governed, tested, production multi-agent workflow** — MCP-driven, end to end.

> Built on [`AAVA-Mastery`](https://github.com/wgpullen/AAVA-Mastery) (the master playbook) and
> [`AAVA-MCP-Server`](https://github.com/wgpullen/AAVA-MCP-Server) (63 RPC tools).

---

## The day at a glance

| | Time | Module |
|---|---|---|
| ☀️ **AM — building blocks** | 0:00 | M0 · Environment Bring-up |
| | 0:30 | M1 · Mental Model + the 11 Commandments |
| | 1:00 | M2 · Problem Decomposition (one agent = one task) |
| | 1:45 | M3 · KBs, Guardrails, Tools |
| | 2:30 | M4 · Agent Creation via Repo + MCP |
| | 3:15 | M5 · Governance — Test → Validate → Approve 1-by-1 |
| 🍽️ | 3:30 | **Lunch (60 min)** |
| 🌆 **PM — capstone** | 4:30 | M6 · Capstone Briefing (Meridian National Bank) |
| | 4:50 | M7 · Design the Pipeline |
| | 5:45 | M8 · Build via MCP |
| | 7:00 | M9 · Test, Debug, Validate |
| | 7:40 | M10 · Approve 1-by-1 & Debrief |

---

## The capstone: COBOL → Spring Boot, with evidence

A fictional client (**Meridian National Bank**) wants two COBOL programs (`CUSTMGMT`, `ACCTPROC`)
modernized to Spring Boot. The previous vendor quoted a 1-for-1 rewrite of *every line*. The board's
constraint: **don't rebuild untouched code — but prove every deletion with data.**

The client handed over the source, copybooks, and a **full year of JCL + CICS production logs**.
Students must build an AAVA pipeline that separates **ACTIVE** code from **DEAD** code and modernizes
only what's live. The exercise has a **deliberate trap**: one program's dead code is statically
reachable and *only the runtime logs* expose it. (Answer: **9 dead / 23 active paragraphs, ~28.9%
scope reduction.** See the Solution Key.)

---

## Repo layout

| Path | What it is |
|---|---|
| `capstone/00-client-brief.md` | The raw client input (Eleanor's email) + artifact inventory + success criteria |
| `capstone/01-student-instructions.md` | Phase 1–5 walkthrough, GitHub raw URLs, MCP build steps |
| `lab-artifacts/source/` | `CUSTMGMT.cbl`, `ACCTPROC.cbl` + `copybooks/` |
| `lab-artifacts/logs/` | `batch_jcl_execution.log`, `cics_transaction.log` (2024 production) |
| `lab-artifacts/knowledge-base/` | `cobol-modernization-standards.txt` (seed KB) |
| `solution-key/SOLUTION-KEY.md` | 🔒 **Instructor only** — decomposition, exact ACTIVE/DEAD analysis, scoring rubric |
| `solution-key/reference-agents/` | The 8 production-validated agent specs |
| `facilitator-guide/FACILITATOR-GUIDE.md` | Per-module timing, talking points, gotchas, exercise answers |
| `quick-reference/QUICK-REFERENCE-CARD.md` | Student one-pager (commandments, MCP cheat-sheet, agentConfigs) |
| `deck/build_aava_advanced_training.py` | python-pptx builder → `AAVA_Advanced_Engineering_Lab_v1.pptx` |

> **Slide decks live outside the repo** (in the Ascendion Windows Training folder). The builder script
> is versioned here; rebuild with `python deck/build_aava_advanced_training.py <output.pptx>`.

---

## Feeding lab data to agents — two paths

1. **Azure Blob (primary):** container `cobol-legacy-modernization`, folders `source/` and `logs/`.
2. **GitHub raw (fallback, no Azure access):**
   ```
   https://raw.githubusercontent.com/wgpullen/AAVA-Advanced-Training/main/lab-artifacts/<path>
   ```
   When on the GitHub path, hardcode the file list in the agent's instructions (Commandment #2:
   always carry a known fallback list — the recursive Azure reader won't enumerate GitHub).

---

## Running the course

1. Send prerequisites a week out (Python 3.9+, Git, Claude Code, AAVA PAT, cloned repos).
2. Instructor reads `facilitator-guide/FACILITATOR-GUIDE.md` and keeps `solution-key/` open in the PM.
3. Print `quick-reference/QUICK-REFERENCE-CARD.md` per attendee.
4. Build/refresh the deck from `deck/`.

*Ascendion internal. Employees only.*
