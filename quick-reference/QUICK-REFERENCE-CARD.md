# AAVA Advanced — Student Quick-Reference Card

*Keep this open all day. Platform: `https://int-ai.aava.ai` · Realm **32** (platformengineeringallteam) · Team **229**.*

---

## The 11 Commandments (never violate)
1. **Reuse before you create** — never rebuild a tool, KB, or guardrail that already exists.
2. `azure_parent_folder` MUST propagate through **all** agents (Agent 1 generates it).
3. Tool names must match **EXACTLY** (including spaces / "Tool" suffix).
4. `AzureBlobWriterTool` param is **`content`**, not `file_content`.
5. Upload code files **before** generating the HTML report.
6. HTML reports: use the **actual SAS URLs** returned by the writer — never construct URLs.
7. Agents fake data instead of calling tools (silent failure) → merge "generate + call tool" into one step.
8. Use **"DO NOT PROCEED"** blocking language on every mandatory tool call.
9. No "Section" numbering inside Steps (Steps 1..N; PART A..G for sub-items).
10. Creation order is **KB → GR → Tool → Agent → Workflow**.
11. Clone an artifact **only** when you must modify one you don't own / that's APPROVED.

## Creation order (and why)
`KB → GR → Tool → Agent → Workflow` — each layer references the one before it. Build bottom-up.

## Decomposition template (Phase 1 → Phase 2)
**Extract 8 elements:** goal · inputs · outputs · constraints · domain rules · risk/compliance ·
success metric · hidden traps. → **Golden Rule: one agent = one independent task.** If an agent does
two things, split it. If you can't test it alone, it's too big.

## agentConfigs block (LLM params nest here!)
```json
"agentConfigs": {
  "aiEngine": "AzureOpenAI",          // or "AmazonBedrock", "GoogleAI"
  "model": "gpt-4o", "modelId": 53,
  "preset": "Deterministic",          // Deterministic = code/parse; Balanced = reports
  "temperature": 0.1, "topP": 0.6,
  "maxIter": 3, "maxRpm": 10, "maxExecutionTime": 1500
}
```
Model picks: technical/parse → gpt-4o (53) or Bedrock Claude (497/493) · reports → Balanced preset.

## Agent instruction skeleton (proven)
```
You are Agent #N in an M-agent pipeline. You receive azure_parent_folder from Agent #N-1.

STEP 1 — <action> (MANDATORY TOOL CALL)
YOU MUST call "<Exact Tool Name>" with: <params>
DO NOT PROCEED until the tool returns <result>.
...
STEP K — Upload via "AzureBlobWriterTool" (content = your markdown). DO NOT PROCEED until SAS URL.
STEP K+1 — Output: azure_parent_folder + SAS URL + handoff summary for Agent #N+1.
```

## Shared tools — REUSE, don't recreate (agents attach tools from ANY realm)
| Tool (exact name) | ID | Realm | Use |
|---|---|---|---|
| `Current DateTime Tool` | 4525 | 32 | generate `azure_parent_folder` |
| `AzureBlobReaderTool` | 4521 | 32 | read one file |
| `AzureBlobWriterTool` | 5964 | 1 | write file + return SAS URL |
| `AzureBlobRecursiveReaderTool` | 8426 | 59 | read all files in a folder |
> When building an agent you can attach a tool from **any** realm — `find_aava_artifact`, then reuse by ID. Don't recreate.

## MCP tool cheat-sheet (Claude Code + `mcp-aava`)
| Task | Tool |
|---|---|
| Verify connection | `test_aava_connection` |
| Check if it exists first | `find_aava_artifact` / `search_aava_artifacts` / `list_aava_artifacts` |
| Inspect full detail | `get_aava_artifact_detail` |
| Create | `create_aava_knowledge_base` · `create_aava_guardrail` · `create_aava_tool` · `create_aava_agent` · `create_aava_workflow` |
| **Unit-test before trusting** | `execute_single_agent` · `execute_single_tool` |
| Run the chain | `trigger_workflow` → `poll_workflow_result` / `stream_workflow_progress_formatted` |
| **Approve 1-by-1 after validation** | `approve_aava_artifact` |
| Modify one you don't own / APPROVED | `clone_aava_artifact` |

## Governance loop (the discipline)
**Build → `execute_single_*` (test) → read output (validate) → `approve_aava_artifact` (one at a time).**
Never approve what you haven't seen produce correct output. Approval body uses `id` (not `agentId`).

## Workflow gotchas
- `create_aava_workflow` needs `workflowConfig: {}` (else 500).
- Every agent after #1 needs the chaining prompt: *"Input your requirements as output from the previous agent."*
- APPROVED workflows can't be edited (PUT 400) → create a new one.
- `pipeLineAgents` only lists EXECUTED agents; `workflowExecutionId` is at `data.workflowExecutionId`.

## Capstone — Meridian National Bank (afternoon)
**Goal:** plan + build COBOL → Spring Boot Java for `CUSTMGMT` + `ACCTPROC`; modernize what drives value.
**Inputs (Azure `cobol-legacy-modernization` OR GitHub `lab-artifacts/`):** `source/*.cbl`,
`source/copybooks/*.cpy`, `logs/batch_jcl_execution.log`, `logs/cics_transaction.log`.
**GitHub raw base:** `https://raw.githubusercontent.com/wgpullen/AAVA-Advanced-Training/main/lab-artifacts/`
**The question you must answer:** *what do you modernize, what do you leave behind, and what's your evidence?*
> 💡 Bring your legacy-modernization instincts. Not every line is worth carrying forward — and the
> client handed you everything you need to decide.
