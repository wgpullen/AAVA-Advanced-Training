# Capstone — Student Instructions

> Read the client brief (`00-client-brief.md`) **first**, and take your first crack at a
> decomposition before opening this file. The single most valuable learning moment of the day is
> discovering the dead-code trap *yourself*.

You have ~3 hours after lunch. Work in your team. You will be **MCP-driven**: you author and push
every artifact into AAVA through Claude Code + the AAVA MCP server, test each one, then approve
them one-by-one. The instructor has the Solution Key and will compare your choices against it in
the debrief.

---

## Phase 1 — Extract the 8 critical elements (15 min, on paper/whiteboard)

From Eleanor's email + the artifact inventory, pull out:

1. **Business goal** — what outcome does the board actually want?
2. **Inputs provided** — what data do you have? (source, copybooks, JCL log, CICS log)
3. **Outputs required** — what must you deliver? (plan, docs, stories, design, code, tests, exec report)
4. **Constraints** — "don't migrate untouched code" *and* "prove every deletion with data."
5. **Domain rules** — banking; COMP-3 = money; statements; interest accrual.
6. **Risk / compliance** — retiring SMEs, board scrutiny, can't delete without evidence.
7. **Success metric** — scope reduction %, faithful active-logic migration.
8. **The hidden trap** — *(you'll name this after Phase 2)*.

## Phase 2 — Decompose into a workflow (25 min)

Apply the **Golden Rule: one agent = one independent task.** Sketch the pipeline. Ask yourself:

- How do I figure out what's actually running vs what just *exists* in the source?
- Can I trust a **static** read of the COBOL alone? (Look closely at `CUSTMGMT`'s `0000-MAIN-CONTROL`
  `EVALUATE` versus `ACCTPROC`'s `0000-MAIN-CONTROL`. One program's dead paragraphs are *unreachable*;
  the other's dead paragraphs are *reachable in code but never triggered in production*. Which is which —
  and which tool catches each?)
- What knowledge does every agent need? (→ a shared KB)
- Where does the handoff data flow? (→ `azure_parent_folder` threaded through every agent — Commandment #2)

> **Stop here.** Lock your decomposition before you build. The instructor will do a 5-minute
> gut-check of each team's pipeline before you start authoring.

---

## Phase 3 — Build via MCP (75 min)

Build in **Commandment #10 order: KB → GR → Tool → Agent → Workflow.**

1. **Reuse, don't recreate.** The Azure tools already exist in realm 32 — find them first:
   ```
   find_aava_artifact(artifact_type="tools", name="AzureBlobWriterTool")
   find_aava_artifact(artifact_type="tools", name="AzureBlobReaderTool")
   find_aava_artifact(artifact_type="tools", name="Current DateTime Tool")
   # recursive reader: confirm the EXACT registered name before wiring it in (Commandment #3)
   ```
2. **KB:** create `cobol-modernization-standards` from
   `lab-artifacts/knowledge-base/cobol-modernization-standards.txt` via `create_aava_knowledge_base`.
   (Or reuse it if it already exists in your realm.)
3. **Agents:** author each agent with `create_aava_agent`. Use the **STEP / "DO NOT PROCEED"**
   instruction pattern. Suffix every agent name with **your initials** so the class doesn't collide.
4. **Workflow:** chain the agents with `create_aava_workflow` (remember `workflowConfig: {}` —
   Commandment / Lesson #4). Every agent after #1 needs the chaining prompt.

### Feeding the data to your agents

**Option A — Azure Blob (primary, matches production):** point agents at container
`cobol-legacy-modernization`, folders `source/` and `logs/`.

**Option B — GitHub raw (if you have no Azure access):** the same files are here. Raw base URL:
```
https://raw.githubusercontent.com/wgpullen/AAVA-Advanced-Training/main/lab-artifacts/
```
| File | Raw URL suffix |
|---|---|
| Customer program | `source/CUSTMGMT.cbl` |
| Account program | `source/ACCTPROC.cbl` |
| Customer copybook | `source/copybooks/CUSTREC.cpy` |
| Account copybook | `source/copybooks/ACCTREC.cpy` |
| JCL batch log | `logs/batch_jcl_execution.log` |
| CICS transaction log | `logs/cics_transaction.log` |

For Option B, give the agent the explicit list of raw URLs in its instructions and have it fetch each
one (a simple web/HTTP reader tool, or paste-in for the analysis agents). The recursive Azure reader
won't enumerate GitHub — so when on the GitHub path, **hardcode the file list** (Commandment / Lesson #2:
always carry a known fallback list).

---

## Phase 4 — Test, validate, approve one-by-one (40 min)

- **Unit test before you trust:** `execute_single_agent` on Agent 1, then Agent 2, reading the output.
  Did Agent 2 correctly flag the dead paragraphs **with log evidence and a reason**?
- **Run the chain:** `trigger_workflow`, then `poll_workflow_result` / `stream_workflow_progress_formatted`.
- **Debug:** if an agent emitted synthetic data instead of calling a tool, that's Commandment #7 —
  tighten the instruction with blocking language and re-run.
- **Approve in order, only after validation:** `approve_aava_artifact` for each KB → tool → agent that
  passed. Never approve something you haven't seen produce correct output.

## Phase 5 — Debrief (final 20 min)

Be ready to answer: **How many paragraphs did you migrate, how many did you retire, and what was your
evidence for each retirement?** The instructor compares your numbers to the Solution Key.
