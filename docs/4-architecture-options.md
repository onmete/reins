# Architecture Options

Where does the orchestration live? `2-workflow-design.md` defines the workflow
(three loops, config hierarchy, guardrails) but is silent on delivery
mechanism. This doc explores the options.

The core question: **standalone service vs. IDE-native harness vs. hybrid.**

## Context

`2-workflow-design.md` line 9 says:

> It is not a separate agent backend. It is a configuration and workflow
> layer that sits on top of existing AI coding CLIs.

The original plan (since replaced) designed a Python FastAPI service
that calls the Anthropic API directly — essentially a separate agent
backend. This doc evaluated alternatives and arrived at Option 5.

## Option 1: Standalone Service

What the original plan described. A Python backend that owns the full
lifecycle.

**Components:**
- FastAPI web server
- Anthropic SDK for LLM calls
- Jira/Slack/GitHub client libraries
- SQLite/PostgreSQL for state
- Custom workflow state machine

**How it works:**
- Jira webhook or poll triggers the service
- Service calls LLM APIs, generates plans, writes code
- Service posts to Slack, creates PRs, tracks state
- Human interacts via Slack and GitHub

**Strengths:**
- Full control over orchestration and state
- Works headless — no IDE required
- Easier to deploy for a team (one instance serves everyone)
- Clean integration testing (it's just a web service)

**Weaknesses:**
- Duplicates what Cursor/Claude Code already do well (LLM context
  management, file editing, test running, git operations)
- Building a good code-editing agent is hard — existing CLIs have
  years of iteration on this
- Higher maintenance burden (LLM API changes, token management,
  context window optimization)
- The engineer loses the IDE feedback loop during implementation

**Assessment:** Viable for team deployment where a shared service is
needed. But for a single-developer local POC, rebuilding the AI
coding engine is unnecessary work — existing CLIs (Claude Code,
Cursor) already handle LLM integration, context management, file
editing, and test execution. The effort is better spent on workflow
orchestration and integration, not on re-implementing capabilities
that already exist. Consider Option 5 instead.

## Option 2: IDE-Native Harness (Configuration Only)

The harness is entirely encoded as files that shape how Cursor or Claude
Code behaves. No custom runtime.

**Components:**
- `.cursor/rules/` — Phase-specific rules (plan, implement, review)
- `AGENTS.md` / `CLAUDE.md` — Coding standards and guardrails
- MCP servers — Jira, Slack, GitHub (community or first-party)
- Prompt templates — Markdown files encoding each phase's instructions

**What the rules look like (Cursor):**

A rule like `.cursor/rules/loop1-plan.mdc` would activate when the
engineer asks about planning a story. It instructs the agent to:
1. Read the Jira story via MCP (description, acceptance criteria)
2. Read repo context (AGENTS.md, relevant source files)
3. Produce a structured plan: files to change, per-criterion approach,
   risk assessment
4. Post the plan to Slack via MCP
5. Output the plan in a specific markdown format for team review

A separate `.cursor/rules/loop2-implement.mdc` activates during
implementation and enforces: follow the approved plan, write tests
alongside code, run tests before committing, produce an adherence
assessment before creating the PR.

For Claude Code, the equivalent lives in `CLAUDE.md` and
`.claude/commands/` — custom slash commands like `/plan OLS-42` and
`/implement OLS-42` that encode the same behavior.

**How it works:**
1. Engineer opens Cursor, references a Jira story
2. Loop 1 rule activates: agent reads story via Jira MCP, proposes
   plan, posts to Slack via Slack MCP
3. After approval, engineer triggers Loop 2: agent implements,
   tests, self-reviews, creates PR
4. Loop 3: human reviews in GitHub, agent addresses feedback

**Strengths:**
- Zero code to build — works with existing tools today
- Leverages battle-tested LLM integration (Cursor's context engine,
  Claude Code's agentic loop)
- Engineer stays in the IDE — full visibility and control
- Portable: rules for Cursor, CLAUDE.md for Claude Code
- Low maintenance — the IDE vendor handles LLM updates

**Weaknesses:**
- Human is the orchestrator — manually sequences the loops
- No persistent workflow state (story progress lives in Jira columns
  and human memory)
- Hard to enforce transitions (nothing stops you from skipping the
  plan phase)
- Jira/Slack MCP servers vary in quality and reliability
- No automation of the workflow itself
- Rule-based behavior is advisory, not enforced — the agent might
  deviate from the rule's instructions under pressure

**Assessment: Recommended as Stage 1.** The fastest path to
validating the workflow design. Zero infrastructure, conversation-
speed iteration. Cursor's sub-agent system with model routing
covers more ground than initially expected (context isolation,
parallel execution, worktree isolation). The reliability ceiling
(rules are advisory, ~90% per `3-harness-engineering.md`) is
acceptable for a single developer validating the design. All
artifacts produced (prompts, rules, formats, MCP configs) carry
directly into Stage 2 (Option 5).

## Option 3: MCP Workflow Server (Hybrid)

A lightweight MCP server that encodes the workflow state machine and
external integrations. The IDE handles everything else (LLM calls, file
editing, test execution).

**Components:**
- Custom MCP server (~500-1000 lines Python) exposing workflow tools
- Cursor rules or CLAUDE.md for phase-specific agent behavior
- AGENTS.md for coding standards and guardrails

**MCP tools exposed:**
- `workflow_start(story_id)` — Read Jira story, set state, return
  context
- `workflow_submit_plan(story_id, plan)` — Post plan to Slack, update
  Jira status
- `workflow_check_approval(story_id)` — Check Slack for approval
- `workflow_begin_implementation(story_id)` — Gate check: is plan
  approved?
- `workflow_submit_pr(story_id, adherence_report)` — Create PR, update
  Jira
- `workflow_state(story_id)` — Return current state
- `guardrails_validate()` — Check work against org-level constraints

**How it works:**
1. In Cursor: "Start planning story OLS-42"
2. Agent calls `workflow_start("OLS-42")` → gets story context
3. Agent generates plan, calls `workflow_submit_plan(...)` → Slack post
4. Agent calls `workflow_check_approval(...)` → confirmed
5. Agent calls `workflow_begin_implementation(...)` → gate passes
6. Agent implements code using Cursor's native tools
7. Agent calls `workflow_submit_pr(...)` → PR created

**Strengths:**
- Portable across Cursor and Claude Code (both support MCP)
- Persistent state (SQLite in the MCP server)
- Enforces workflow transitions (gate checks prevent skipping phases)
- External integrations are centralized and testable
- IDE handles what it's good at (LLM, editing, testing)
- MCP server handles what the IDE can't (workflow state, Jira/Slack
  integration, guardrail enforcement)

**How rules and MCP work together:**

The MCP server owns state and integrations. The rules own agent
behavior. Neither works well alone:
- Without rules, the agent has workflow tools but no instructions on
  when or how to use them. It might call `workflow_submit_pr` before
  running tests.
- Without the MCP server, the rules describe the workflow but can't
  enforce it. Nothing prevents the agent from skipping straight to
  implementation.

Together: rules tell the agent *what to do at each phase*, and MCP
tools *gate transitions between phases*. The agent can't begin
implementation until `workflow_begin_implementation()` confirms the
plan is approved. The rule tells the agent to call that tool before
writing code.

**Weaknesses:**
- Requires building and running the MCP server
- Another process to manage locally (`npx`/`uvx` or Docker)
- MCP protocol still maturing — some rough edges
- Two configuration surfaces (rules + MCP) to keep in sync

**Assessment:** Attractive on paper — clean separation of concerns,
portable across IDEs. But has a fundamental control flow problem:
**the agent decides when to call MCP tools.** The MCP server can
enforce gates *when called*, but it cannot force the agent to call
it. If the agent skips `workflow_begin_implementation()` and starts
coding directly, the MCP server never gets a say. Enforcement is
still advisory — it depends on the LLM following rules, which is
exactly the reliability problem this option was supposed to solve.
The harness needs to be in charge, not the agent.

## Option 4: Claude Code CLI Scripting

Use Claude Code's headless mode (`claude -p "prompt"`) driven by a
shell or Python script that sequences the three loops.

**Components:**
- Orchestrator script (Python or bash, ~500 lines)
- Claude Code CLI (`claude -p` for headless invocation)
- Jira/Slack/GitHub client libraries in the script
- Prompt templates per phase

**How it works:**
```
# Loop 1: Plan
plan=$(claude -p "Read story OLS-42 via Jira MCP. Propose an
  implementation plan following the format in docs/plan-template.md"
  --mcp-server jira)

# Post plan to Slack, wait for approval (script handles this)

# Loop 2: Implement
claude -p "Implement the approved plan: $plan. Run tests. Produce
  adherence assessment." \
  --allowedTools "Edit,Write,Shell,Grep"

# Loop 3: Self-review + PR
claude -p "Review implementation against acceptance criteria.
  Create PR with adherence report."
```

Each loop is an isolated Claude invocation with a clean context
window. The orchestrator script handles transitions, state, and
external integrations between invocations.

**Strengths:**
- Full automation — no human in the loop between phases (if desired)
- Each loop gets a clean context window (no context pollution)
- Easy retry/timeout logic in the script
- Claude Code's `--allowedTools` flag provides per-phase tool scoping
- Session transcripts provide audit trail

**Weaknesses:**
- Claude Code-specific (Cursor has no headless CLI mode)
- Loses the interactive IDE experience — engineer can't steer
  mid-implementation
- The orchestrator script essentially becomes a standalone service
  (converges toward Option 1 with Claude Code as the LLM runtime)
- Context between loops is limited to what the script passes (no
  shared memory or conversation history)

**Assessment:** The right idea — backend drives, agent executes —
but too thin as a shell script. Lacks proper state management,
error handling, and integration structure. However, the core
insight is correct: **invert the control flow so the harness is in
charge, not the agent.** This idea is refined into Option 5.

## Option 5: Backend-Driven with CLI Runtime

Inverts the control flow from Option 3. Instead of the agent
deciding when to call workflow tools, a **deterministic backend**
drives the workflow and delegates AI tasks to an agent CLI runtime.
The backend enforces; the agent executes.

This is the programmatic harness pattern from
`3-harness-engineering.md`, but using an existing agent CLI as the AI
runtime instead of raw LLM API calls — avoiding the need to rebuild
file editing, context management, and test execution (Option 1's
main weakness).

### Why Agent CLIs, Not Raw LLM APIs

Raw LLM API endpoints (OpenAI, Vertex, Anthropic API) provide
inference and tool/function calling — text in, text out. An agent
CLI provides the full runtime on top of that: file editing with
smart diffing, agentic tool-use loop (plan → execute → observe →
iterate), context window management, shell execution, git
operations, error recovery, and safety guardrails.

Using a raw API would require building all of that in the backend
— thousands of lines of code and months of iteration. That's
Option 1 territory. The whole point of Option 5 is to avoid
rebuilding the agent runtime.

### Available Agent CLI Runtimes

| CLI Runtime | Models | Headless mode | Notes |
|-------------|--------|---------------|-------|
| **Claude Code** | Claude (Anthropic) | `claude -p` | Production, mature |
| **Codex CLI** | OpenAI models | `codex -q` | Production, OpenAI |
| **aider** | Any (OpenAI, Anthropic, Vertex, Ollama, local) | `aider --message` | Mature OSS, model-agnostic |
| **goose** (Block) | Multiple providers | CLI mode | OSS, newer |

The backend should abstract the runtime behind an adapter
interface so the agent CLI is swappable:

```
class AgentRuntime:
    invoke(prompt, allowed_tools, working_dir) -> Result

ClaudeCodeRuntime   → claude -p "..." --allowedTools ...
CodexRuntime        → codex -q "..." --full-auto
AiderRuntime        → aider --message "..." --model ...
```

The workflow state machine, integrations, and enforcement logic
are identical regardless of which runtime is behind the adapter.
Start with Claude Code for the POC; add adapters as needed.

**Components:**
- Python backend (~1000-1500 lines) — state machine, integrations
- `claude-agent-sdk` (Python) — primary runtime via native SDK.
  Fallback to CLI subprocess for other runtimes (Codex, aider)
- SQLite — workflow state persistence
- Jira/Slack/GitHub client libraries — in the backend, not the agent
- Prompt templates per phase — stored as files, injected by backend
- `AGENTS.md` / `CLAUDE.md` — coding standards (read by the agent
  runtime automatically when invoked in the repo)

**How it works:**
```
Backend (deterministic Python):
  1. Read story from Jira                    [deterministic]
  2. Invoke: claude -p "Generate plan..."    [AI - Loop 1]
  3. Post plan to Slack                      [deterministic]
  4. Poll Slack for approval                 [deterministic]
  5. Invoke: claude -p "Implement plan..."   [AI - Loop 2]
  6. Invoke: claude -p "Self-review..."      [AI - Loop 2b]
  7. Parse adherence score                   [deterministic]
  8. If score < threshold → retry step 5     [deterministic]
  9. Create PR with adherence report         [deterministic]
```

Every transition is enforced in code. Claude never sees the full
workflow — it gets a focused task with focused context. The backend
decides what happens next based on deterministic logic.

**Per-phase context isolation:**

Each Claude invocation gets only what it needs:
- **Plan phase:** story context + repo structure + AGENTS.md
- **Implement phase:** approved plan + relevant source files +
  coding standards. Tool scoping via `--allowedTools` (edit, write,
  shell, grep — no network access)
- **Self-review phase:** acceptance criteria + implementation diff +
  adherence template. Read-only tools only

**Strengths:**
- Backend is deterministically in charge — no hoping the agent
  follows rules
- Reuses the agent CLI's full capabilities (context engine, file
  editing, test execution, git) without rebuilding them
- Each phase gets a clean context window (no pollution)
- Per-phase tool scoping via CLI flags
- Deterministic retry, timeout, and error recovery
- Session transcripts from each invocation provide audit trail
- Maps directly to programmatic harness patterns: fixed plans,
  sub-agent isolation, state management, phase-based checkpointing
- Backend handles integrations (Jira, Slack, GitHub) — the agent
  doesn't need MCP servers for these
- Adapter pattern enables runtime portability — swap between Claude
  Code, Codex CLI, aider without changing workflow logic
- Model-agnostic via aider (supports OpenAI, Anthropic, Vertex,
  Ollama, local models)

**Weaknesses:**
- Engineer can't steer mid-phase — each agent invocation runs to
  completion. Interactive steering requires falling back to Option 2
  or 3 for that phase
- Another local process to run (the backend)
- Agent CLI APIs may change (still relatively new ecosystem)
- Cost: each phase is a separate session, potentially re-reading
  repo context. Token usage may be higher than a single long-running
  session
- Adapter quality varies — each CLI has different capabilities,
  output formats, and tool scoping mechanisms. Lowest-common-
  denominator risk if trying to support all of them equally

**Assessment: Recommended for POC, with caveats.** This option
inverts the control flow so the harness drives the workflow
deterministically, while delegating AI tasks to a battle-tested
runtime. It avoids Option 1's trap (rebuilding the AI coding engine)
and Option 3's trap (hoping the agent follows the rules). The
backend is small (~1000-1500 LoC), focused on orchestration and
integrations. Use `claude-agent-sdk` (Python) for the primary
runtime — not CLI subprocess — to get typed responses, hooks,
streaming, and custom tool injection. See "Critical Evaluation"
section for risks and mitigations, particularly around intra-phase
quality and token cost. Orca (`orcastrator`) is direct prior art
for this pattern and should be studied before building. Can coexist
with Option 2 — the engineer uses Cursor interactively for ad-hoc
work on the same repo while the backend handles the structured
workflow.

## Critical Evaluation of Option 5

Research into prior art and real-world experience with agent CLI
orchestration reveals both validation and serious risks.

### What Validates the Approach

**Orca exists and works.** `happycatlabs/orca` (npm: `orcastrator`)
is essentially Option 5 for OpenAI Codex. It breaks tasks into a
graph, executes them via persistent Codex sessions, has a gate
engine (G0-G7) enforcing quality at each phase, supports autonomous
and human-gated modes, and exposes a JSON-RPC API for multiple
clients (CLI, IDE extensions, desktop apps). 138 commits, actively
maintained. This is direct validation that the pattern works.

**Claude Agent SDK exists (Python).** `claude-agent-sdk` (v0.1.50,
Mar 2026) provides native Python integration — not just subprocess
invocation. Two modes: `query()` for one-off tasks (each phase) and
`ClaudeSDKClient` for multi-turn sessions with persistent context.
Supports async streaming, hooks, custom tools as in-process MCP
servers, and structured output. This is a better integration path
than shelling out to `claude -p`.

**Headless mode is mature.** Claude Code's `-p` flag supports
`--max-turns`, `--max-budget-usd`, `--allowedTools`, JSON output,
streaming, and input piping. Over 40% of advanced users use it in
CI/CD as of 2026. Not experimental.

**Industry convergence.** OpenAI (Codex App Server), Anthropic
(Claude Agent SDK), and multiple open source projects (Orca, aider)
are all building toward the same pattern: a programmatic harness
that invokes agent capabilities rather than rebuilding them.

### Blockers and Hard Problems

**1. Intra-phase quality is not enforced.**

Option 5 enforces *transitions between phases* but not what
happens *within* a phase. In practice, well-crafted prompts,
skills, and context engineering should handle this — the whole
point of harness engineering is making the agent's environment
legible enough that it does the right thing.

However, evidence suggests this isn't guaranteed. A study of
336 Gemini CLI sessions found self-review skipping in ~40% of
sessions and scope boundary violations in ~30% of multi-file
sessions — despite explicit instructions. Whether this is a
model quality issue (Gemini vs. Claude) or a fundamental LLM
limitation remains an open question.

If it proves to be a problem, the backend can add deterministic
validation around each phase: structured output schemas, running
tests independently, diff scope checking against the plan's file
list, and retry with escalation.

**2. Session boundary amnesia.**

Each phase is a fresh session with no memory of previous phases.
This is correct by design — each phase takes the *output* of the
previous phase, not its full history. The plan phase may iterate
through multiple drafts, but the implementation phase only needs
the final approved plan, not the discussion that produced it.
Phase outputs are structured artifacts (plan, implementation
diff, adherence report) stored in `.ai-sdlc/`. The repo is the
shared memory.

The engineering task is defining what each phase's output artifact
looks like — but that's workflow design, not a risk.

**3. Token cost multiplication.**

Each isolated session re-reads repo context from scratch. A
three-phase workflow reads repo context three times.

Largely solvable through **model routing** — use a capable model
for the plan phase (broad understanding, architectural reasoning)
and cheaper/faster models for implementing individual plan items
and self-review (narrower scope, focused tasks). The plan phase
can also break work into granular items so each implementation
invocation has a small, well-defined scope with minimal context.
This is the same pattern described in `3-harness-engineering.md`:
expensive model for the orchestrator, cheaper model for sub-tasks.

Additional mitigations: per-phase budget caps, backend
pre-selecting relevant files based on the plan's file list, and
SDK session reuse where context pollution isn't a concern.

**4. Rate limit collisions.**

Possible with sequential invocations hitting per-minute ceilings.
Unlikely to matter for POC (single-story flow). Revisit if it
becomes a practical problem.

**5. Agent CLI/SDK instability.**

The ecosystem is young and not GA-stable. Acceptable for POC —
use the simplest path that works, not the most robust.

**6. "Agent orchestrators are bad" counterargument.**

The blog post (12gramsofcarbon.com) argues orchestrators cost
significantly more than single-agent approaches while producing
worse output. The overhead of context splitting, injection, and
phase management may not justify the workflow enforcement.

Counter-counter: This critique targets *multi-agent parallelism*
(multiple agents working on the same codebase simultaneously)
without proper isolation. Git worktrees solve the "stomp on each
other's code" problem — each agent operates in its own working
directory on its own branch. The backend could run parallel
stories in separate worktrees with no file conflicts. Option 5
starts as sequential orchestration (one story at a time) but
worktree-based isolation is the natural path to concurrency
when needed. The coordination overhead of *isolated parallel*
agents is much lower than shared-workspace agents.

### Revised Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Intra-phase quality (skipped reviews) | High | High (~40%) | Structured output + external validation |
| Token cost multiplication | Medium | High | Budget caps + context filtering |
| Session amnesia | Medium | Certain | Phase artifacts in repo |
| Rate limits | Low | Low (POC) | Backoff + budget caps |
| CLI/SDK instability | Medium | Medium | Simple invocations, avoid subagents |
| Orchestrator overhead not worth it | Low | Low | Sequential, not parallel |

The highest risk — intra-phase quality — is not unique to Option 5.
It affects every approach that uses LLMs. The difference is that
Option 5's backend can add deterministic validation *around* each
phase, which Options 2-4 cannot.

## What Converges Across Options

Regardless of delivery mechanism, all options share:

- **The three-loop workflow** — Plan → Implement+Self-Review → Review.
  The loops are the same; only where they execute differs.
- **Guardrails** — Context exclusions, approved models, locked
  standards. These are enforced differently (code vs. config vs. MCP
  tools) but the policies are identical.
- **Adherence assessment** — Agent self-scores against acceptance
  criteria before human review. The format and threshold are the same.
- **Integration points** — Jira for stories, Slack for discussion,
  GitHub for PRs. The APIs are the same; only the client differs.
- **Configuration hierarchy** — Org → Team → Repo → User. How
  config is distributed changes (central server vs. git submodule
  vs. MCP resource), but the merge semantics are the same.

**What shifts under Option 5 (vs. Option 1):**

| Component | Service (Option 1) | Backend + CLI (Option 5) |
|-------------------|--------------------|-----------------------|
| Plan Generator | Python module, Anthropic SDK | Backend invokes Claude CLI |
| Code Implementer | Python module, file I/O | Claude CLI (native file editing) |
| Self-Reviewer | Python module, Anthropic SDK | Claude CLI (separate invocation) |
| Workflow Orchestrator | Custom state machine | Backend state machine (same) |
| Config Manager | Python module | AGENTS.md + backend config |
| LLM integration | Anthropic SDK, token mgmt | Claude CLI handles (zero maint.) |
| Test execution | subprocess/pytest calls | Claude CLI runs tests natively |
| Integrations | In the service | In the backend (same) |

The core insight: Option 5 keeps the backend's control flow (the
harness drives, not the agent) while delegating AI tasks to a
battle-tested runtime instead of rebuilding them.

## Comparison

| Dimension | Service | IDE-Native | MCP Hybrid | CLI Script | Backend+CLI |
|-----------|---------|------------|------------|------------|-------------|
| Code to build | ~3000+ | ~0 | ~500-1000 | ~500 | ~1000-1500 |
| Workflow enforcement | Strong | Weak | Appears strong* | Strong | Strong |
| Who drives | Backend | Human | Agent | Script | Backend |
| IDE integration | None | Full | Full | None | None** |
| Portability | Any client | Per-IDE | MCP-capable | Claude Code | CLI agents |
| Persistent state | Yes | No | Yes | Yes | Yes |
| Team deployment | Easy | Per-dev | Per-dev | Per-dev | Per-dev |
| Maintenance burden | High | Low | Medium | Medium | Medium |
| LLM engine | Custom | IDE | IDE | Claude CLI | Claude CLI |

\* MCP Hybrid enforcement is conditional — it only works when the
agent calls the MCP tools. The agent can bypass them.

\** Engineer can use Cursor interactively on the same repo alongside
the backend. They're complementary, not exclusive.

## Recommendation: Staged Approach

The hardest part isn't the backend — it's getting the prompts,
context engineering, and workflow design right. Build those first
where iteration is fastest (the IDE), then add infrastructure.

### Stage 1: Local Agent Skills (Option 2)

Validate the workflow design with zero infrastructure.

**Build:**
- Agent skills (SKILL.md format) for each workflow loop — open
  standard portable across Cursor, Claude Code, Codex, Copilot,
  and 27+ agents
- Prompt templates for plan generation, implementation, self-review
- Plan format (YAML frontmatter + markdown sections)
- Adherence assessment format and scoring criteria
- MCP server integration (Jira, optionally Slack)
- Cursor sub-agents with model routing (capable model for planning,
  fast model for focused implementation tasks)

**Validate:**
- Does the three-loop workflow produce better outcomes than ad-hoc
  prompting?
- Do the prompt templates generate useful plans?
- Does the adherence assessment catch real issues?
- What context does each phase actually need?

**Output:** A set of tested, proven artifacts — prompts, rules,
formats, MCP configs. All directly reusable in Stage 2. If the
workflow doesn't improve outcomes at this stage, no amount of
backend engineering will fix that.

### Stage 2: Backend Harness (Option 5)

Wrap the proven flows in a deterministic backend.

**Build:**
- Python backend (~1000-1500 LoC) using `claude-agent-sdk`
- Same prompts from Stage 1, now invoked via `query()`
- Persistent state (SQLite), automatic Jira transitions
- Per-phase tool scoping and model routing
- Headless operation — run a story start-to-finish unattended

**What's new vs. Stage 1:**
- Deterministic phase transitions (code, not LLM judgment)
- Persistent state across sessions
- Unattended operation
- Reproducible runs

The design work is done. This stage is engineering, not
experimentation.

### Stage 3: Multi-User / Team Service

The backend evolves into a team coordination layer.

**What changes:**
- Loop 1 (plan discussion) becomes multi-user — the team
  collaborates on the plan in Slack before the agent implements.
  This is where the structure adds genuine value over a single
  developer doing it in their IDE.
- Shared state across developers (who's working on what, which
  stories are in which phase)
- Org-level guardrails distributed to all team members
- Metrics and observability (interrupt rate, adherence scores,
  cycle time)

**Why this is last:** A single developer can hold the workflow in
their head. Team coordination is where structural enforcement
becomes essential — you can't rely on everyone following the same
rules manually.

### Why This Order Works

Each stage validates and feeds the next:
- Stage 1 proves the workflow design works (or doesn't)
- Stage 2 adds enforcement and automation around proven flows
- Stage 3 adds the team coordination that justifies the harness

Nothing is wasted between stages — prompts, formats, and
integration logic carry forward. And the biggest risk (does the
workflow actually help?) is tested first, at the lowest cost.

## Partnership Model: IDE Vendor + Workflow Layer

Options 2-4 share an assumption: the IDE is the agent runtime and we
don't rebuild what it already does well. Taken further, this frames
AI-SDLC not as a standalone product but as a **team coordination layer**
that partners with an IDE vendor — Cursor being the most natural fit.

**What the IDE vendor provides (the brain):**

- LLM integration, context engine, token management
- Code editing, file I/O, inline diffs
- Test execution, terminal, debugger
- Git operations (branch, commit, push)
- MCP client protocol support

**What AI-SDLC provides (the flows):**

- Workflow state machine (plan → implement → review gates)
- Jira integration (story intake, status tracking, column transitions)
- Slack integration (plan posting, threaded discussion, approval via
  reactions)
- GitHub integration (PR creation with adherence reports, review
  feedback relay)
- Org-level guardrails (approved models, context exclusions, locked
  policies)
- Configuration hierarchy (Org → Team → Repo → User)
- Adherence assessment orchestration (agent self-scoring against
  acceptance criteria)

**Why this split works:**

- **Clean boundary.** The IDE doesn't want to build Jira/Slack
  workflows and enterprise policy engines. The workflow layer doesn't
  want to build an LLM context engine and code editor. Neither side
  duplicates the other.
- **MCP is the interface.** Both Cursor and Claude Code already support
  MCP. The workflow layer slots in as an MCP server — no proprietary
  API coupling. If the IDE vendor changes, the MCP contract stays.
- **Enterprise enabler.** Org-level guardrails (approved models, security
  policies, coverage thresholds) are exactly what enterprise buyers need
  before adopting AI coding tools at scale. The workflow layer becomes a
  sales enabler for the IDE vendor's enterprise motion.
- **Config hierarchy maps to their business model.** Org → Team → Repo →
  User mirrors how enterprises think about policy. Cursor today is
  single-developer; this layer makes it team-aware without Cursor
  building team management itself.

**Risks:**

- The IDE vendor could build this in-house or acquire a competitor. The
  moat is workflow design quality and integration depth, not technology.
- Tight coupling to one vendor's MCP implementation details (despite MCP
  being a protocol, implementations vary in maturity and capability).
- The value is clearest for enterprises with existing Jira/Slack/GitHub
  toolchains; less compelling for teams using different stacks.

**How this relates to the options:**

Option 3 (MCP Hybrid) is the natural architecture for this model. The
MCP server is the partnership surface — it encodes workflow state,
gates, and integrations; the IDE provides the agent runtime. Option 1
(standalone service) is the fallback if the partnership model doesn't
materialize, since it can operate without an IDE.

## Open Questions

- Can Jira column position serve as the state machine, eliminating
  the need for a separate state store?
- How portable does the harness need to be across Cursor, Claude Code,
  and OpenCode?
- Should the MCP server be a single process or composed from separate
  Jira/Slack/GitHub/workflow servers?
- How do org-level guardrails get distributed to developer machines?
  Git submodule? Published package? Central config server?
- What's the minimum viable workflow enforcement that adds value
  over pure configuration (Option 2)?
- Is there a path to co-development or partnership with an IDE vendor
  (Cursor, Anthropic/Claude Code), or should the workflow layer stay
  vendor-neutral from the start?

## Prior Art

- **Orca** (`happycatlabs/orca`, npm: `orcastrator`) — Coordinated
  Codex run harness. Plan-execute-review workflow with gate engine
  (G0-G7), persistent sessions, autonomous/gated modes, JSON-RPC
  API. Closest existing implementation of Option 5, targeting
  OpenAI Codex. https://orcastrator.dev/
- **OpenAI Codex App Server** — Official harness infrastructure:
  thread lifecycle, config management, gate engine. Exposed via
  JSON-RPC for CLI/IDE/desktop clients.
  https://openai.com/index/unlocking-the-codex-harness/
- **Claude Agent SDK** (`claude-agent-sdk`, PyPI) — Python SDK for
  programmatic Claude Code invocation. `query()` for one-off tasks,
  `ClaudeSDKClient` for multi-turn. v0.1.50 as of Mar 2026.
  https://github.com/anthropics/claude-agent-sdk-python
- **Gemini CLI instruction-following study** — 336 sessions, 6
  prompt engineering interventions. Self-review skipping ~40%,
  scope violations ~30%, session-boundary amnesia. Directly
  relevant to Option 5's intra-phase quality risk.
  https://github.com/google-gemini/gemini-cli/issues/22261
- **"Agent orchestrators are bad"** — Counterargument: orchestrators
  cost more, produce worse output than single-agent approaches.
  Critiques multi-agent parallelism more than sequential
  orchestration. https://12gramsofcarbon.com/p/agent-orchestrators-are-bad
- **86-session Claude Code orchestrator study** — Hard-won lessons
  on context injection, delimiter-based passing, and phase
  boundary management.
  https://dev.to/ji_ai/building-a-multi-agent-llm-orchestrator-with-claude-code-86-sessions-of-hard-won-lessons-13n6
- **Ansible ARC Harness** — Configuration layer over AI CLIs with
  four-level hierarchy. Validates the "not a separate backend"
  approach at org scale.
- Additional prior art (Ansible ARC, agent-tasks-template)
  referenced in `5-references.md`.
