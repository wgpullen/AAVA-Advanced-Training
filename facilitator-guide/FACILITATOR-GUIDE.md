# Facilitator Guide — AAVA Advanced Engineering Course

**Audience:** Ascendion engineers / solution architects / delivery leads (employees only).
**Format:** 1 day · 8 hours · instructor-led, hands-on. **Build mode:** MCP-driven (Claude Code + AAVA MCP server).
**Pre-reqs sent 1 week prior:** laptop with Python 3.9+, Git, Claude Code, an AAVA PAT, and access to
the two repos (`AAVA-Mastery`, `AAVA-MCP-Server`) + this repo (`AAVA-Advanced-Training`).

> This guide gives any Ascendion SME everything to run the day: timing, talking points, the
> gotcha callouts per module, and the exercise answers. The Solution Key (`solution-key/`) is the
> companion you keep open during the afternoon. **Do not screen-share the Solution Key.**

---

## Day-at-a-glance

| Block | Time | Module |
|---|---|---|
| ☀️ AM | 0:00–0:30 | M0 · Environment Bring-up |
| | 0:30–1:00 | M1 · AAVA Mental Model + the 11 Commandments |
| | 1:00–1:30 | M2 · Problem Decomposition: "One Agent = One Task" |
| | 1:30–1:45 | ☕ Break |
| | 1:45–2:30 | M3 · Mastering KBs, Guardrails, Tools |
| | 2:30–3:15 | M4 · Mastering Agent Creation via Repo + MCP |
| | 3:15–3:30 | M5 · Governance: Test → Validate → Approve 1-by-1 |
| 🍽️ | 3:30–4:30 | **LUNCH (60 min)** |
| 🌆 PM | 4:30–4:50 | M6 · Capstone Briefing (Meridian National Bank) |
| | 4:50–5:30 | M7 · Design the Pipeline (gut-check each team) |
| | 5:30–5:45 | ☕ Break |
| | 5:45–7:00 | M8 · Build via MCP |
| | 7:00–7:40 | M9 · Test, Debug, Validate |
| | 7:40–8:00 | M10 · Approve 1-by-1, Submit & Debrief |

**Golden thread for the whole day:** *"AAVA is one agent per critical task. The hardest, most
valuable skill is deciding what the tasks ARE — and proving your decisions with evidence."*

---

## ☀️ MORNING

### M0 · Environment Bring-up (0:00–0:30)
**Goal:** everyone green before you teach a single concept. Setup failures kill afternoon momentum.

Walk the room through:
1. Clone `AAVA-Mastery` and `AAVA-MCP-Server`; run `setup.py` (validates PAT, resolves realm 32 / team 229).
2. Confirm the MCP server is registered (`mcp-aava` in `~/.claude.json`).
3. Run `test_aava_connection` — expect `✅ ... Realm: 32 ... Token valid`.
4. Clone this repo (`AAVA-Advanced-Training`) for the afternoon lab artifacts.

**Gotcha callouts:**
- PAT expired / wrong realm → `setup.py` re-prompts. Have 2–3 spare PATs ready.
- Zscaler can block SSO; the PAT path is what we use, so it's fine.
- Anyone who can't get MCP working pairs with a neighbor — they can still do the UI fallback, but
  the course is designed for MCP.

### M1 · AAVA Mental Model + the 11 Commandments (0:30–1:00)
**Talking points:**
- The five primitives: Tool, Agent, Workflow, Guardrail, KB; + Realm as the org boundary.
- Creation order is law: **KB → GR → Tool → Agent → Workflow** (Commandment #10).
- Walk the 11 Commandments from `AAVAAdvancedProblemSolvingSystem.md`. Spend the most time on:
  - **#2** azure_parent_folder threading (the #1 cause of broken chains),
  - **#3** exact tool-name matching,
  - **#7** synthetic-data silent failure,
  - **#8** "DO NOT PROCEED" blocking language.
- Frame: *the Commandments are scar tissue from 16 real client projects — each one prevents a
  specific, expensive failure.*

**Mini-exercise (5 min):** show a broken agent prompt; have the room spot which Commandment it violates.

### M2 · Problem Decomposition: "One Agent = One Task" (1:00–1:30)
**This is the intellectual core of the morning** and the skill the afternoon tests.
- Phase 1: the 8 critical elements you extract from raw client input.
- Phase 2: proven pipeline patterns; how-many-agents heuristic.
- **Live decomposition drill (15 min):** give the room a one-paragraph problem (NOT the capstone —
  use a small one, e.g. "release-notes from merged PRs"). Have tables propose the agent breakdown.
  Reveal a clean 3-agent answer. Reinforce: each agent is independently testable.

**Gotcha callout:** the rookie move is one mega-agent that "does everything." Mega-agents can't be
tested, debugged, or reused. One task per agent = one thing that can fail = one thing you can fix.

### M3 · Mastering KBs, Guardrails, Tools (1:45–2:30)
- **KB:** what belongs in a KB vs a prompt (regulatory refs, schemas, mappings, long lists → KB).
  Show the `cobol-modernization-standards` KB as a model: it encodes the COBOL→Spring mapping and
  the dead-code criteria so every agent shares one source of truth.
- **Guardrail:** Tier-1 (platform) vs Tier-2 (domain). Colang (exact match) vs YAML (semantic).
  **Commandment #1: never attach guardrails to workflows — only agents.**
- **Tool:** the 8-rule contract (no secrets in source, stdlib only, schema = LLM-visible inputs,
  right HTTP shape, dual-status poll, hyphenated var names, full toolConfig on PUT). **Reuse the
  shared Azure tools — never recreate.**
- **Micro-labs:** (a) create a tiny KB via `create_aava_knowledge_base`; (b) `find_aava_artifact`
  the AzureBlob tools so everyone sees reuse-before-create in action.

### M4 · Mastering Agent Creation via Repo + MCP (2:30–3:15)
- The agent instruction template: **Role → Goal → Context → Output → Rules**, STEP 1..N with a
  MANDATORY TOOL CALL and "DO NOT PROCEED" on each. Show Agent 1 & Agent 2 from `reference-agents/`.
- `agentConfigs` structure (LLM params nest in `agentConfigs` — the Jun-1 MCP fix). Model selection:
  technical → Bedrock Claude / gpt-4o; the reference pipeline uses gpt-4o Deterministic for parsing.
- **Push to AAVA via MCP:** `create_aava_agent`. Mention the **Revelio safeguard** (auto-restores
  `description` + `expectedOutput` if Revelio overwrites them).
- **Live demo:** author one agent end-to-end via MCP, show it land as DRAFT/CREATED in AAVA.

### M5 · Governance: Test → Validate → Approve 1-by-1 (3:15–3:30)
- The discipline: `execute_single_agent` / `execute_single_tool` to validate **before** trust.
- Then `approve_aava_artifact` one at a time — only after you've seen correct output.
- Super Admins can self-approve; approval body uses `id` not `agentId` (Lesson #3).
- This is the exact loop they'll run in M9–M10. Set the expectation now.

---

## 🌆 AFTERNOON — Capstone

### M6 · Capstone Briefing (4:30–4:50)
- Hand out `capstone/00-client-brief.md`. Read Eleanor's email aloud — it sells the stakes.
- Emphasize the board's constraint: *"don't rebuild untouched code, but prove every deletion."*
- **Do NOT reveal the trap.** Let them find it.
- Point them at the artifacts (Azure container `cobol-legacy-modernization` OR GitHub `lab-artifacts/`).

### M7 · Design the Pipeline (4:50–5:30) — **gut-check every team**
- Teams produce a decomposition on the whiteboard before building.
- **Your gut-check (5 min/team):** the single question that separates pass from fail —
  *"How will you know what's actually running vs what just exists in the source?"*
  - If they have **no runtime-log step** → nudge: "You have a full year of JCL and CICS logs. What
    are they for?" Don't give the answer.
  - If they plan a static-only analysis → ask them to trace `CUSTMGMT`'s `0000-MAIN-CONTROL`
    `EVALUATE` by hand. Let them discover archive/purge/migrate are reachable in code.
- Compare to Solution Key §1. The right shape is ~8 agents; accept 6–9 as long as Parse + **Runtime
  Analysis** + active-scoped downstream + Exec Report are all present.

### M8 · Build via MCP (5:45–7:00)
- Build order KB → (GR) → Tool → Agent → Workflow. Reuse the Azure tools.
- Circulate. Watch for: recreating tools, missing `workflowConfig: {}`, no chaining prompt,
  agents not threading `azure_parent_folder`, weak (non-blocking) instructions.
- Remind teams to suffix agent names with initials to avoid collisions.

### M9 · Test, Debug, Validate (7:00–7:40)
- `execute_single_agent` on Agent 1 then Agent 2. **The validation moment:** did Agent 2 output a
  dead-code inventory with exec counts + reasons? If it hand-waved, it didn't read the logs
  (Commandment #7) — coach them to add blocking language and re-run.
- Run the full chain (`trigger_workflow` → `stream_workflow_progress_formatted` /
  `poll_workflow_result`). Debug failures using the test-run progression in the playbook.

### M10 · Approve 1-by-1, Submit & Debrief (7:40–8:00)
- Approve validated artifacts in order.
- **Debrief — go team by team:** *"How many paragraphs did you retire, and what's your evidence?"*
  - Right answer: **9 dead / 23 active**, ~28.9% scope reduction, evidenced by 0-exec counts +
    stale last-run dates (Solution Key §3).
  - Spotlight any team that caught the `CUSTMGMT` static-reachability trap — that's mastery.
- Close on the business framing: the previous vendor quoted a 1-for-1 rewrite. AAVA's runtime
  intelligence cut ~29% of scope **with evidence the board can defend.** That's the Ascendion edge.

---

## Exercise answer keys (quick reference for the instructor)

- **M1 mini-exercise** — typical planted violations: guardrail on a workflow (#1), tool name
  mismatch (#3), no blocking language (#8), missing `azure_parent_folder` (#2).
- **M2 drill (release-notes example)** — clean answer: Agent 1 PR/commit extractor → Agent 2
  release-notes writer → Agent 3 formatter/publisher. Three independently testable tasks.
- **Capstone** — full answers in `solution-key/SOLUTION-KEY.md` §3 (the 9 dead paragraphs, per program,
  with evidence) and §5 (10-point scoring rubric).

## Logistics checklist
- [ ] PATs issued to all attendees (+ 3 spares) and realm 32 access confirmed.
- [ ] `cobol-legacy-modernization` Azure container staged (or students use GitHub `lab-artifacts/`).
- [ ] Repos cloneable from attendee laptops (test one the day before).
- [ ] Decide whether the class shares realm 32 (initials suffix is mandatory) or uses per-squad realms.
- [ ] Printed Quick-Reference Card per attendee (`quick-reference/QUICK-REFERENCE-CARD.md`).
