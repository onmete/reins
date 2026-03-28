# Harness Engineering

Research notes on the emerging discipline of harness engineering and its
relationship to the AI-SDLC design.

## Origin

The term originates from Mitchell Hashimoto's blog post ("My AI Adoption
Journey," Step 5: Engineer the Harness) and was subsequently popularized by
OpenAI in a February 2026 blog post by Ryan Lopopolo ("Harness engineering:
leveraging Codex in an agent-first world"). As Birgitta Böckeler notes on
martinfowler.com, OpenAI's formal coining "was maybe an afterthought inspired
by" Hashimoto's earlier usage. The OpenAI post describes the discipline that
emerged from a five-month experiment where a small team (3→7 engineers) built
and shipped a beta product with ~1 million lines of code and zero
manually-written lines, using Codex agents exclusively.

The metaphor is borrowed from horse tack — reins, saddle, bit — equipment
for channeling a powerful but unpredictable animal in the right direction:

- **The horse** is the AI model — powerful, fast, directionless on its own
- **The harness** is the infrastructure — constraints, guardrails, feedback
  loops that channel the model's power productively
- **The rider** is the human engineer — providing direction, not doing the
  running

## Core Definition

Harness engineering is the design and implementation of systems that:

1. **Constrain** what an AI agent can do (architectural boundaries,
   dependency rules)
2. **Inform** the agent about what it should do (context engineering,
   documentation)
3. **Verify** the agent did it correctly (testing, linting, CI validation)
4. **Correct** the agent when it goes wrong (feedback loops, self-repair
   mechanisms)

Martin Fowler describes it as "the tooling and practices we can use to keep
AI agents in check" — but emphasizes it's more than safety. A good harness
makes agents more capable, not just more controlled.

## Two Meanings of "Harness"

The term "harness" is being used in the industry for two fundamentally
different things. This matters because the skills required, the
architecture, and the trade-offs are very different.

### Convention Harness (OpenAI, Fowler)

What OpenAI describes is a **convention and configuration layer** that
sits around existing general-purpose agents (Codex, Claude Code,
Cursor). There is no custom agent backend. The "harness" is:

- `AGENTS.md` and structured `docs/` directory
- Custom linters with remediation instructions in error messages
- Structural tests enforcing dependency layering
- CI validation pipelines
- Pre-commit hooks
- Recurring cleanup tasks (themselves run by the same agents)

The agent runtime is off-the-shelf (Codex CLI). The engineering is in
the **repository environment** — making it legible, constrained, and
self-correcting so that a general-purpose agent produces reliable
output. The human writes zero code; they design the environment.

This is what AI-SDLC aligns with most directly. The three-loop
workflow, configuration hierarchy, and guardrails are all convention
harness concepts — shaping how existing AI CLIs behave without
building a custom backend.

### Programmatic Harness (AI Automators, LangGraph, CrewAI)

What the video demonstrates is a **custom software backend** — a
Python application that IS the agent runtime:

- A **state machine** in Python driving an 8-phase pipeline
- A **database** (Supabase `harness_runs` table) tracking phase and
  status of each run
- **Programmatic sub-agent spawning** — Python code creates LLM API
  calls, controls context injection, collects structured outputs
- A **virtual file system** with per-phase checkpoint files
- **Programmatic output generation** from templates (Word docs)
- **Model routing** — orchestrator uses one model, sub-agents use a
  cheaper model
- A **web UI** (React) showing plan, files, and conversation
- **Tool guardrails** — code controls which tools each agent can use

This is building an agent framework, not configuring one. It's closer
to LangGraph, CrewAI, or a custom orchestration system. The harness
IS software — Python, a database, an API, a frontend.

### Why the Distinction Matters

| Dimension           | Convention Harness              | Programmatic Harness            |
|---------------------|----------------------------------|---------------------------------|
| Agent runtime       | Off-the-shelf (Codex, Claude)   | Custom-built (Python + LLM API) |
| What you build      | Docs, linters, CI rules, tests  | Backend application             |
| Skills required     | Architecture, documentation     | Software engineering + architecture |
| Flexibility         | Limited to agent's capabilities | Unlimited (it's code)           |
| Reliability ceiling | Depends on the agent runtime    | Can enforce deterministic steps |
| Maintenance burden  | Low (mostly config/docs)        | High (it's a product)           |
| Domain              | Primarily software development  | Any business workflow            |
| Best for            | Shaping existing agent behavior | Custom multi-stage workflows    |

The video's key argument is that prompting alone (skills, markdown
instructions) has a reliability ceiling. A programmatic harness can
guarantee steps happen — not hope the LLM follows instructions. This
is particularly relevant for business workflows (contract review,
compliance audits) where deterministic output formatting and
auditability are required.

OpenAI's counter-argument (implicit): if the general-purpose agent
runtime is capable enough and the convention harness is well-designed,
you don't need custom orchestration software. Codex runs for 6+ hours
autonomously, drives Chrome DevTools, queries observability stacks —
the runtime itself is increasingly capable.

Both are valid. The question is where the reliability engineering
happens: in the repository environment (convention harness) or in
custom orchestration code (programmatic harness). In practice, most
production systems will likely use both — a convention harness for the
codebase + programmatic harnesses for specific high-reliability
workflows.

## Harness Delivery Mechanisms

The harness is the system of constraints, context, verification, and
correction. But those rules need to reach the agent somehow. Skills,
AGENTS.md, linters, and programmatic backends are all **delivery
mechanisms** — different ways of getting the harness into the agent's
operating context.

| Mechanism              | When it loads       | What it delivers                    |
|------------------------|---------------------|-------------------------------------|
| `AGENTS.md` / system prompt | Always (ambient) | Map, conventions, global rules     |
| Skills (`SKILL.md`)    | On demand (progressive) | Workflow-specific constraints + procedures |
| Linters / CI           | At validation time  | Mechanical enforcement              |
| Structural tests       | At validation time  | Architectural invariants            |
| Agent teams (IDE-native) | On spawn          | Parallel orchestration, peer review, file ownership |
| Programmatic backend   | At runtime          | Deterministic orchestration         |

This reframes the relationship between skills and harnesses. Skills
are not a separate concept from harness engineering — they are one
delivery channel for it. A skill like `reins-implement` delivers
harness constraints (follow the plan, stay in scope, tests alongside
code, stop if the plan is wrong) packaged as a modular, on-demand
unit. The constraints are the harness; the SKILL.md format is how they
reach the agent.

### The Mega-Prompt Problem

Lanham (Feb 2026) argues that monolithic system prompts are breaking:
token costs scale linearly with prompt size, the "lost-in-the-middle"
effect causes models to ignore instructions buried in long contexts,
and tool schemas alone can consume 55K-100K+ tokens before a single
user message arrives.

The fix is progressive disclosure — the same pattern OpenAI advocates
for `AGENTS.md`. Three levels:

1. **Metadata** (~100 tokens/skill) — name + description loaded at
   startup. 50 skills = ~5K tokens for discovery.
2. **Instructions** (SKILL.md body, <5K tokens) — loaded only when
   the agent activates the skill for the current task.
3. **Resources** (scripts, references, assets) — loaded only when
   instructions explicitly call for them.

This is token-efficient (10K vs. 50K+ for an equivalent mega-prompt),
composable (multiple skills combine without merging), portable (same
SKILL.md format works across Claude, Codex, Copilot, LangChain), and
version-controllable (Git workflows for organizational knowledge).

### Skills as Organizational Asset

The durable investment is the skill library, not the runtime. "The
model and agent harness will change, but your skill library is a
versioned asset you can port, audit, and continuously improve"
(Lanham). The `reins-*` skills in this project would survive a switch
from Claude Code to Codex or any other runtime.

### Security Concern

SkillsBench found that 26% of analyzed skills contained vulnerability
patterns (prompt injection, data exfiltration, privilege escalation).
Skills bundling executable scripts were 2.12x more likely to contain
vulnerabilities. This supports AI-SDLC's guardrails model — org-level
policies restricting what skills can do, with `allowed-tools`
frontmatter and sandboxed execution.

## The Three Pillars (OpenAI Convention Harness)

### 1. Context Engineering

Ensuring the agent has the right information at the right time.

**Static context:**
- Repository-local documentation (architecture specs, API contracts,
  style guides)
- `AGENTS.md` treated as a table of contents (~100 lines), not an
  encyclopedia
- Structured `docs/` directory as the single source of truth
- Cross-linked design documentation validated by linters

**Dynamic context:**
- Observability data (logs, metrics, traces) accessible to agents
- Directory structure mapping at agent startup
- CI/CD pipeline status and test results
- Chrome DevTools Protocol wired into agent runtime for UI inspection

Critical rule: from the agent's perspective, anything it can't access
in-context doesn't exist. Knowledge in Slack threads, Google Docs, or
people's heads is invisible. The repository must be the system of record.

**Progressive disclosure:** agents start with a small, stable entry point
(`AGENTS.md`) and are taught where to look next, rather than overwhelmed
with all context up front.

### 2. Architectural Constraints

Mechanical enforcement of what good code looks like, not documentation
alone.

**Dependency layering:**
```
Types → Config → Repo → Service → Runtime → UI
```
Each layer can only import from layers to its left. Enforced by structural
tests and CI validation, not convention.

**Enforcement tools:**
- Deterministic linters with remediation instructions in error messages
- LLM-based auditors (agents reviewing agents)
- Structural tests (like ArchUnit but for AI-generated code)
- Pre-commit hooks
- "Taste invariants" — structured logging, naming conventions, file size
  limits

Paradox: constraining the solution space makes agents more productive.
When an agent can generate anything, it wastes tokens exploring dead ends.
Clear boundaries help it converge faster on correct solutions.

### 3. Entropy Management ("Garbage Collection")

AI-generated codebases accumulate entropy — documentation drifts from
reality, naming conventions diverge, dead code accumulates, agents
replicate suboptimal patterns already present in the repo.

OpenAI initially spent every Friday (20% of engineering time) manually
cleaning up "AI slop." That didn't scale.

Solution: encode "golden principles" into the repository and run recurring
cleanup agents on a cadence:
- Documentation consistency agents
- Constraint violation scanners
- Pattern enforcement agents
- Dependency auditors

Technical debt treated as garbage collection — pay it down continuously
in small increments rather than let it compound.

## Key Evidence

### "The model is commodity, the harness is moat"

LangChain improved their coding agent from 52.8% to 66.5% on Terminal
Bench 2.0 — jumping from Top 30 to Top 5 — by changing nothing about
the model. Changes were all harness-level:

| Change                  | What they did                         |
|-------------------------|---------------------------------------|
| Self-verification loop  | Pre-completion checklist middleware    |
| Context engineering     | Directory structure mapping at startup|
| Loop detection          | Tracked repeated file edits           |
| Reasoning sandwich      | High reasoning for plan/verify, medium for impl |

Same model. Different harness. Dramatically better results.

### OpenAI's Production Proof Point

- 5 months, ~1,500 PRs merged
- ~1 million lines of code, zero manually written
- 3.5 PRs per engineer per day (throughput increased as team grew)
- Built in ~1/10th the time of manual coding
- Product has internal daily users and external alpha testers
- Single Codex runs regularly work 6+ hours on a task (often overnight)

### Industry Convergence

Stripe's internal "Minions" produce 1,000+ merged PRs per week with
the same pattern: human posts task → agent writes code → agent passes
CI → agent opens PR → human reviews and merges. No developer interaction
between task posting and PR review.

Major AI labs (OpenAI, Anthropic, Google DeepMind, Anysphere) independently
converged on nearly identical harness architectures without coordination.

## How the Engineer's Role Changes

| Before                    | After                                          |
|---------------------------|------------------------------------------------|
| Write code                | Design environments where AI writes code       |
| Debug code                | Debug agent behavior                           |
| Review code               | Review agent output + harness effectiveness    |
| Write tests               | Design test strategies                         |
| Maintain docs             | Build documentation as machine-readable infra  |
| Manual cleanup ("Friday slop") | Automated garbage collection agents       |

Engineers shift from writing code to designing environments, specifying
intent, and building feedback loops. This requires deeper architectural
thinking — designing systems that work without constant intervention.

## Harness vs. Related Concepts

| Concept               | Scope                | Focus                              |
|-----------------------|----------------------|------------------------------------|
| Prompt Engineering    | Single interaction   | Crafting effective prompts         |
| Context Engineering   | Model context window | What information the model sees    |
| Harness Engineering   | Entire agent system  | Environment, constraints, feedback |
| Agent Engineering     | Agent architecture   | Internal agent design and routing  |
| Platform Engineering  | Infrastructure       | Deployment, scaling, operations    |

Harness engineering includes context engineering and draws from prompt
engineering, but operates at a higher level — the complete system that
makes agents reliable.

## Alignment with AI-SDLC

The AI-SDLC design and harness engineering are converging on the same
principles from different starting points.

### Strong Overlap

| AI-SDLC Concept                     | Harness Engineering Equivalent             |
|--------------------------------------|--------------------------------------------|
| Three loops (Plan → Implement → Review) | Human steers, agent executes workflow   |
| Configuration hierarchy (Org→Team→Repo→User) | Layered constraint enforcement    |
| Guardrails (non-negotiable org policies) | Mechanical invariant enforcement       |
| Adherence assessment (self-scoring)  | Self-verification loops                    |
| `AGENTS.md` as convention source     | `AGENTS.md` as table of contents / map     |
| "CEO of your backlog" philosophy     | Engineer as environment designer           |
| "Structure dictates behavior" metrics | Harness effectiveness measurement         |
| Entry/exit gates on workflows        | Blocking/non-blocking merge gates          |
| Interrupt → structural fix cycle     | Struggle → diagnose missing capability     |
| Session lessons / feedback loops     | Human taste fed back into tooling          |

### Where Harness Engineering Goes Further

Areas that AI-SDLC could adopt or adapt:

1. **Repository as sole system of record.** OpenAI is more absolute —
   if it isn't in the repo, it doesn't exist for the agent. AI-SDLC
   still plans via Slack threads, which are invisible to future agent
   runs. Execution plans should be versioned artifacts in the repo.

2. **Agent-to-agent review and the review responsibility split.**
   OpenAI pushes almost all review to agent-to-agent. AI-SDLC's
   Loop 3 is human review. The harness engineering model suggests
   agent review as the norm, with human review as escalation. Claude
   Code agent teams make this concrete: a QA teammate with fresh
   context reviewing developer agents' work before the human ever
   sees it.

   In practice, experienced reviewers already don't comment on code
   correctness — they focus on three concerns:

   1. **What is missing** — gaps the plan and spec didn't cover
   2. **When will it break** — fragility and failure modes
   3. **Is it the right thing** — fitness for purpose, direction

   None of these are inherently beyond AI capability. AI can check
   for gaps against acceptance criteria. AI can reason about edge
   cases and failure modes — possibly better than humans for
   mechanical fragility. AI can assess fitness against the story
   spec and even the parent epic if given access.

   The real gap is **context availability, not capability.** Humans
   hold undocumented knowledge — prior failures, operational
   patterns, customer conversations, cross-team dependencies —
   that doesn't exist in the repo. The harness engineering response
   is to progressively encode that context (architecture decision
   records, runbooks, operational notes) so AI review can cover
   more of it over time.

   What remains genuinely human is **questioning the requirement
   itself** — "even though this matches what was asked, the ask
   was wrong" — and judgment in novel situations with no precedent
   in the codebase.

   This implies AI review should be mandatory (not optional) before
   human review. It handles correctness AND partially covers these
   strategic concerns when given sufficient context. The human
   review then focuses on the residual: the context that isn't yet
   encoded in the repo.

3. **Observability as agent input.** Agents querying logs via LogQL,
   metrics via PromQL, traces via TraceQL. Agents that can boot the
   app, drive the UI via Chrome DevTools Protocol, reproduce bugs,
   and validate their own fixes. AI-SDLC doesn't yet address this.

4. **Progressive disclosure for context.** The explicit pattern of a
   small `AGENTS.md` pointing to a structured `docs/` directory with
   indexed design docs, execution plans, and quality grades. More
   prescriptive than AI-SDLC's current guidance.

5. **Entropy management as a formal concern.** Dedicated garbage
   collection agents running on a cadence. AI-SDLC doesn't yet
   address codebase entropy from AI-generated code.

6. **Throughput-adapted merge philosophy.** Minimal blocking gates,
   short-lived PRs, corrections cheaper than waiting. AI-SDLC's
   three-loop model may need adaptation for high-throughput agent
   environments.

7. **"Boring technology" selection.** Preferring dependencies that
   agents can fully internalize and reason about. Sometimes
   reimplementing functionality is cheaper than working around opaque
   upstream behavior.

### Where AI-SDLC Adds Value

1. **Team-level workflow orchestration.** Harness engineering focuses
   on the agent-repository interface. AI-SDLC addresses the broader
   team workflow: how stories flow from Jira through planning to
   implementation to review.

2. **Configuration hierarchy.** The Org → Team → Repo → User layering
   with inheritance and locked guardrails is more structured than
   what OpenAI describes (they operate as a single team on a single
   product).

3. **Risk tiering.** AI-SDLC (via ThoughtWorks) applies different
   review rigor based on change risk. Harness engineering doesn't
   differentiate — it applies the same harness uniformly.

4. **Skill development emphasis.** AI-SDLC explicitly calls out that
   engineers need to understand *why* each gate exists, not just use
   the scaffold. Harness engineering assumes competent engineers
   designing the harness.

## The Reliability Problem: March of Nines

Andrej Karpathy's "March of Nines" concept frames why harness engineering
is necessary. For a 10-step agentic workflow at 90% success per step,
running 10 times a day produces over 6 failures daily. At 99% per step,
you're down to ~1 failure/day. At 99.9%, ~1 failure every 10 days.

The implication: prompting alone ("agent skills") can get you to the
first 90%, but each additional nine of reliability requires comparable
engineering effort. Skills are portable markdown files describing
procedures — essentially just prompts. SkillsBench evaluated 84 popular
skills across all models and found success rates well below what
businesses need for unattended operation.

The harness is what closes the gap: deterministic rails with validation,
state management, and programmatic control around the AI.

## Programmatic Harnesses (Beyond Software Development)

The AI Automators (YouTube, Mar 2026) demonstrated a programmatic
harness — a custom Python backend — for contract review. This is a
different animal from OpenAI's convention harness. It applies to any
complex multi-stage business workflow: compliance audits, risk
analysis, financial reports.

### Harness Architecture Patterns

| Pattern              | Description                                    | Example          |
|----------------------|------------------------------------------------|------------------|
| General-purpose      | Broad coding/task agent with tool access        | Claude Code, Manis |
| Specialized          | Fixed-phase pipeline for a domain workflow      | Contract review  |
| Autonomous           | Event-triggered, self-directed agents           | OpenClaw         |
| Hierarchical         | Supervisor orchestrating sub-agents             | Stripe Minions   |
| Team                 | Parallel peers with shared task list + messaging| Claude Code teams|
| DAG                  | Graph-based with branching and parallel exec    | Complex pipelines|

### Key Design Principles from the Demo

1. **Fixed vs. dynamic plans.** Specialized harnesses use fixed plans
   (8 deterministic phases for contract review). General-purpose
   harnesses allow dynamic plans where the LLM generates and modifies
   its own to-dos. For reliable business processes, fixed plans are
   preferred — "I don't want the LLM making it up as it goes along."

2. **Sub-agent context isolation.** Each sub-agent gets a fresh context
   window with only the information it needs. The orchestrator's context
   stays lean. A contract with 34 clauses spawns dedicated sub-agents
   for risk analysis of each clause — 323K total tokens across
   sub-agents while the main agent used only 7K tokens.

3. **Model routing.** Different models for different tasks. Expensive
   model (Gemini 2.5 Pro) for the orchestrator; cheaper model (Gemini
   2.5 Flash) for narrow sub-agent tasks. Cost control without
   sacrificing accuracy on specialized, narrow tasks.

4. **Phase-based file system.** Each phase writes its output to a file.
   If the process fails at phase 6, you can restart from phase 5's
   output. Resilience through checkpointing.

5. **Programmatic output generation.** The final Word document is
   generated from a template programmatically — not by asking the LLM
   to generate a document. Deterministic formatting means consistent
   output every time.

6. **State management.** The harness is a state machine. A database
   table tracks which phase each harness run is in. The state machine
   logic is codified in Python.

7. **Validation loops.** The weakest area in pure-prompt approaches.
   Claude Code does this well for code (generate → test → fix → loop).
   For business workflows, equivalent loops might include fact-checking,
   comparing proposed changes against a playbook, or cross-referencing
   extracted data against source documents.

### 12 Design Considerations for Agent Harnesses

From the video's framework:
1. Harness architecture (pattern selection)
2. Planning (fixed vs. dynamic)
3. File system (virtual scratch pad, workspace isolation)
4. Task delegation (sub-agents with context isolation)
5. Tool calling (with guardrails on which tools are available)
6. Memory (short-term as markdown files, long-term as knowledge
   graphs or persistent storage)
7. State management (state machine, phase tracking in database)
8. Code execution (sandboxed environments for generated code)
9. Context management (compaction, summarization, file-based
   context offloading)
10. Human in the loop (clarifying questions, approval gates)
11. Validation loops (self-checking, fact-checking, playbook
    comparison)
12. Agent skills (expandable capabilities within the harness)

## Agent Teams (IDE-Native Multi-Agent Orchestration)

Claude Code (Mar 2026) introduced agent teams — an experimental feature
for spawning multiple parallel agents within the IDE runtime. This sits
between convention harnesses and programmatic harnesses: the
orchestration is built into the agent runtime, but the behavior is
shaped by convention (prompts, file ownership rules, skills).

### How Agent Teams Work

The main Claude Code session acts as a **team lead**. It creates
teammate agents that:

- Run in parallel, each with their own context window
- Share a **task list** managed by the team lead
- Can **message each other directly** (peer-to-peer, not just through
  the orchestrator)
- Inherit permissions, MCP servers, and skills from the main session
- Have no conversation history — they only know what the team lead
  tells them at spawn time

This is distinct from sub-agents, which work independently and return
results to the main agent. Agent teams enable feedback loops: a QA
agent can reject a developer agent's work and send it back directly.

### Agent Teams vs. Sub-Agents

| Dimension            | Sub-Agents                   | Agent Teams                    |
|----------------------|------------------------------|--------------------------------|
| Communication        | Report to main only          | Peer-to-peer + main            |
| Work pattern         | Sequential / isolated        | Parallel / collaborative       |
| Shared state         | None                         | Shared task list               |
| Context              | Fresh, scoped by main        | Fresh, scoped by main          |
| Best for             | Focused single-result tasks  | Multi-specialty parallel work  |
| Cost                 | 1 extra session per call     | N sessions running concurrently|

### Prompting Pattern

Effective agent team prompts follow a structure:

1. **Goal** — what the team is collectively building (agents wake up
   with no context; the goal orients them)
2. **Team definition** — number of agents, model tier (Haiku/Sonnet/
   Opus), named roles
3. **Per-agent spec** — responsibilities, files owned, deliverables,
   who to message when done
4. **Communication flow** — explicit: "when done, message the QA
   agent," "wait for backend's API before starting"
5. **Final deliverables** — what the main agent should collect and
   present to the human

### Key Constraints

- **File ownership** — each agent edits only its own files. Without
  this, agents overwrite each other's work. This is an architectural
  constraint (Pillar 2) enforced by convention in the prompt.
- **3-5 teammates max** — N agents ≈ N× cost. Larger swarms increase
  cost without proportional quality gains.
- **Explicit recipients** — agents don't infer who to talk to. Name
  the recipient in the prompt or messages go nowhere.
- **Full context upfront** — no history is carried over. Everything
  the agent needs must be in its spawn prompt or readable from the
  project.

### Plan Approval Mode

Agent teammates can be required to **plan first** and get approval
before executing. The approver can be:

- The main agent (automated gate)
- The human (manual gate)
- A designated reviewer teammate

This maps directly to AI-SDLC's Loop 1→Loop 2 gate: plan, get
approval, then implement. The difference is that the gate happens
per-agent rather than per-story.

### Visibility and Human Oversight

In a tmux terminal, each agent gets its own pane — the human can
watch all agents think and work simultaneously. The human can also
message any individual agent, not just the orchestrator. This supports
the "CEO of your backlog" model: the engineer supervises a team of
agents rather than delegating blindly.

### Clean Shutdown Protocol

The main agent sends shutdown requests to teammates. Each teammate
can **refuse** if it hasn't finished saving work. Only when all
confirm ready does the session close. This prevents work loss from
force-killing agents mid-task — a small but important reliability
detail.

### Relevance to AI-SDLC

Agent teams operationalize several AI-SDLC concepts within Claude
Code's native feature set:

| AI-SDLC Concept              | Agent Team Implementation              |
|------------------------------|----------------------------------------|
| Loop 1 gate (plan approval)  | Plan approval mode per teammate        |
| Loop 2 (implement + review)  | Parallel dev agents + QA agent loop    |
| Adherence assessment         | Separate QA agent with fresh context   |
| File ownership boundaries    | Per-agent file assignment in prompt     |
| Human as supervisor          | Tmux split-pane, individual messaging  |

The QA agent pattern is particularly relevant: rather than the
implementing agent self-scoring its own adherence (grading its own
homework), a separate QA agent with a fresh context window reviews
the work independently. This is a stronger verification signal.

For the Stage 1 local POC, agent teams are available today with a
single environment variable. A `reins-team-implement` skill could
encode the team structure (frontend + backend + QA), file ownership
rules, communication flow, and plan approval mode — delivering
AI-SDLC's workflow through Claude Code's native orchestration.

## ARC: Prior Art from the Ansible Team

The Ansible team built **ARC (Agent Runtime Configuration)** — a
CLI-agnostic hierarchical configuration and workflow framework for
AI-augmented development. Presented as an executive pitch for a 30-day
pilot (Mar 2026), it's the most concrete internal implementation of
the harness concepts described above.

### What ARC Is

ARC is a configuration layer — not a new platform or CLI. It delivers
three capabilities:

1. **Unified Configuration.** One canonical format (`*.ai.md`,
   `*.mcp.json`, `*.skills.md`, `*.workflow.md`) that translates into
   native files for any AI CLI. Write once, works everywhere.

2. **Hierarchical Governance.** Four levels — org, team, repo, user —
   where each level augments the one above. The org locks security
   policies, approved models, and mandatory integrations. No level
   below can override.

3. **Structured Workflows.** 14 out-of-the-box SDLC workflows with
   entry/exit gates, auto-generated system prompts, and automatic
   recording.

ARC is implemented as an AI CLI skill — one markdown file. The
developer's own AI assistant reads the skill and configures itself.

### ARC's Four-Level Hierarchy

```
ORG (org-ai-config repo)
    agents.md ........................ Root entry point for all AI
    coding-standards.ai.md ........... Language conventions, review rules
    code-structure.ai.md ............. Module layout, naming, architecture
    test-guidance.ai.md .............. Test frameworks, coverage strategy
    security-policy.ai.md ............ Context exclusions, approved providers
    governance.ai.yaml ............... LOCKED constraints (models, CLIs, thresholds)
    org.mcp.json ..................... Mandatory MCP servers (Jira, Confluence)
    skills/ .......................... git-workflow, code-review, jira-integration
    workflows/ ....................... 14 standard SDLC workflows

TEAM (.ai/ in team config repo)
    config.ai.md ..................... Team entry point (includes parent → org)
    coding-standards.ai.md ........... Team-specific additions (appended to org's)
    component.mcp.json ............... Team MCP servers (e.g., team API docs)
    skills/ .......................... Team-specific skills
    workflows/ ....................... Team workflow overrides

REPO (.ai/ in the project repo)
    config.ai.md ..................... Repo entry point (includes parent → team)
    architecture.ai.md ............... THIS repo's architecture, patterns, deps
    test-guidance.ai.md .............. THIS repo's test strategy and conventions
    repo.mcp.json .................... Repo-specific MCP servers
    skills/ .......................... Repo-specific skills (e.g., local-dev)
    workflows/ ....................... Repo-specific workflow overrides

USER (~/.config/arc/)
    config.ai.md ..................... Personal preferences, CI agent behavior
    user.mcp.json .................... Personal MCP servers (e.g., Slack)
```

### Config Merge Rules

| Content Type | Merge Strategy | Example |
|---|---|---|
| Instructions (`*.ai.md`) | **Append** — org first, then team, then repo, then user | Org coding standards appear first. Team additions append after. |
| MCP Servers (`*.mcp.json`) | **Deep merge by name** — lower wins on conflict, except mandatory servers | Org defines `jira-mcp` as mandatory. Team adds `team-api-docs`. |
| Skills (`*.skills.md`) | **Union** — all levels contribute; same filename at lower level wins | Org provides `git-workflow`. Team can override with their version. |
| Workflows (`*.workflow.md`) | **Union** — same as skills | Org provides `story-implementation`. Repo can override for its needs. |
| Governance | **Not merged** — org only, defines locked constraints | `governance.ai.yaml` is the authority. Period. |

The repo-level `architecture.ai.md` is what makes ARC work on
**existing codebases**. It teaches the AI about the service's
architecture, dependencies, patterns, and history — context that a
greenfield project doesn't need but every established codebase
requires.

### Governance That Scales

`governance.ai.yaml` lives in org-ai-config. No level below can
override it:

```yaml
locked:
  mcp-servers: ["jira-mcp", "confluence-mcp"]
  settings:
    approved-models: ["claude-opus-4-6", "claude-sonnet-4-6",
                      "claude-haiku-4-5-20251001"]
    approved-clis: ["claude-code", "opencode", "cursor"]
    context-exclusions: ["**/.env", "**/*.pem",
                         "**/secrets/**", "**/credentials*"]
  instructions:
    locked-files: ["security-policy.ai.md",
                    "coding-standards.ai.md"]

required:
  files: ["config.ai.md"]
  sections: ["security", "testing"]

test-coverage:
  unit-threshold: 80
  component-threshold: 70
  exclude-from-coverage: ["**/*_generated.go", "**/mocks/**"]

workflow-recordings:
  repository: "git://github.com/myorg/arc-workflow-logs"
  upload: "mandatory"
  local-retention: "ask"
```

### Distribution Model

Two repos with distinct responsibilities:

| Repo | Purpose | Example Targets |
|---|---|---|
| `harness` | Makefile modules for tooling | `make ai-setup`, `make aap-dev-start`, `make test-unit`, `make lint` |
| `org-ai-config` | AI configuration and governance | Skills, workflows, `governance.ai.yaml`, `agents.md` |

A project adds **one line** to its Makefile:

```makefile
-include $(shell gh api repos/myorg/harness/contents/bootstrap.mk \
    --jq '.content' | base64 -d > .harness.mk && echo .harness.mk)
```

Generated files are gitignored. No changes to repo structure. Fully
reversible — remove one Makefile line and it's gone.

### The 14 Workflows

ARC ships with 14 workflows organized by SDLC phase, each mapping to
a step in an existing agile process:

**Planning:** Feature Ideation, PRD/RFE
**Specification:** System Design Plan (SDP), Tech Proposal
**Decomposition:** Epic Creation, Epic Breakdown
**Execution:** Story Implementation, Bugfix, Spike Research
**Quality:** Test (orchestrator), Test-Unit, Test-Component, Triage,
Code Review

Every workflow follows the same lifecycle, enforced by ARC:

```
1. [ARC]       Evaluate ENTRY GATES (halt if any fail)
2. [ARC]       Start recording
3. [ARC]       Assemble system prompt:
                 Role       — who the AI acts as
                 Task       — what to accomplish
                 Context    — loads .ai.md files, fetches from
                              MCP servers, user input
                 Reasoning  — thinking constraints
                 Stop Conds — when the loop ends
                 Output     — expected deliverable format
4. [WORKFLOW]   Execute PROCESS LOOP (the actual work)
5. [ARC]       Evaluate EXIT GATES (loop back to 4 if any fail)
6. [ARC]       Stop recording
7. [ARC]       Upload recording to shared repository
8. [ARC]       Ask user: "Keep a local copy?"
```

The workflow author defines Entry Gates, Process Loop, and Exit Gates.
ARC handles everything else: prompt assembly, recording, upload,
governance validation.

### Workflow Recording

Every workflow execution is automatically captured and uploaded:

| Field | Captured | Why It Matters |
|---|---|---|
| Who | Developer identity | Attribution and usage patterns |
| When | Timestamp, duration | Velocity measurement |
| Where | Repo, branch, commit SHA | Traceability to code changes |
| What | Workflow name, Jira issues | Links AI activity to work items |
| How | Full system prompt, all context, every tool call | Reproducibility and audit |
| Result | AI-generated summary, deliverables | Outcome assessment |

Searchable index by user, workflow, repo, date, or Jira issue.

### ARC's Core Argument

The presentation's thesis: greenfield proved AI-augmented development
works, but **existing codebases are the real test**. The Nexus team
(spec-kit on greenfield) sidesteps the hard problems: legacy patterns,
flaky tests, historical architectural decisions, inter-service
dependencies, and per-developer tool fragmentation.

ARC bridges this by providing the configuration layer, governance, and
structured workflows that make AI-augmented development work on any
codebase — not just a blank slate. The 30-day pilot proposal: one
team, one existing codebase, fully reversible, deliverable is
data-backed SDLC recommendations.

### Relationship to Reins

ARC and Reins are **peers, not parent-child.** Both are team-level
harnesses built independently for different organizations within
Red Hat. They converge on many of the same patterns because the
underlying problem (governing AI agents in an SDLC) drives similar
solutions:

| ARC Concept | Reins Equivalent |
|---|---|
| Four-level hierarchy (org/team/repo/user) | Configuration hierarchy (Org → Team → Repo → User) |
| `governance.ai.yaml` (locked, cannot override) | Guardrails (non-negotiable org policies) |
| 14 SDLC workflows with entry/exit gates | Three-loop workflow with gates |
| Workflow recording (who/when/where/what/how/result) | Session recording, adherence assessment |
| `architecture.ai.md` (teaches AI about existing code) | `AGENTS.md` as convention source |
| CLI-agnostic canonical format | CLI-agnostic design (skills work across runtimes) |
| Story Implementation with adherence scoring | Loop 2 + adherence assessment |

Key differences:

- **Scope:** ARC covers the full SDLC chain (14 workflows from
  feature ideation through testing). Reins focuses on the
  implementation loop (spec → plan → implement → review).
- **Feedback loop:** Reins has `reins-retro` — a mechanism for
  improving skills based on each execution's failures. ARC records
  executions but doesn't define how recordings drive improvement.
- **Maturity:** ARC has a full implementation targeting Claude Code
  with Makefile-based distribution. Reins has working skills
  validated on real stories, with the backend planned for Stage 2.
- **CLI support:** ARC's implementation currently generates Claude
  Code native files only (Cursor/OpenCode support is designed but
  not yet built). Reins skills work in Cursor today.
- **Org size:** ARC targets a 200+ person organization. Reins starts
  with a single developer's workflow and scales up.

Neither team needs to adopt the other's format. Both will operate
as tenants within the enterprise platform, receiving shared policy
from above and contributing audit data upward. Where patterns
converge (config hierarchy, governance, recording format), the
enterprise platform may standardize the interface — but the skills
and workflows inside each harness are each team's own.

## Enterprise Harness: The Red Hat-Wide Vision

Jeremy Eder's requirements go beyond what ARC or any existing harness
design addresses. The Ansible team's ARC is scoped to one
organization (~200 developers). Jeremy's vision is an enterprise
governance platform covering all of Red Hat — thousands of developers
across dozens of organizations with different tools, processes, and
maturity levels.

### The Four Differentiators

**1. Enterprise-wide scope, not team-scoped.**

ARC's four-level hierarchy (org/team/repo/user) assumes a single
org-ai-config repo maintained by one architecture team. At Red Hat
scale, "org" is ambiguous — is it the Ansible BU? The OpenShift
platform team? The entire company?

The enterprise harness must cover all of Red Hat. This implies a
hierarchy deeper than four levels, or a federated model where each
BU/org maintains its own config that inherits from a company-wide
root.

**2. Non-developer primary users — admin UX is required.**

ARC is developer-facing. Developers run `/arc setup` and `/arc sync`
in their terminal. The AI reads markdown files.

Jeremy's primary audience is **non-business users** — the admins,
managers, and governance operators who configure and enforce policy.
They need a real UX: a web interface or admin console where they can
browse the hierarchy, edit policies, see who's using what, and push
changes. "Edit a YAML file in a git repo" is not an admin UX.

This is the biggest architectural fork from ARC. It likely means a
**service** (API + UI) that manages the configuration hierarchy,
rather than a pure git-based convention harness. The convention
harness pattern still works for the developer-facing delivery (agents
read files), but the management plane needs to be a product.

**3. Policy inheritance following the management chain.**

ARC's hierarchy is technical: org → team → repo → user. Jeremy wants
inheritance that mirrors the actual management structure: Hicks →
Wright → Your_VP → you/your-team.

This means the hierarchy is not static — it needs to know the org
chart. When a VP sets a policy, it flows down to every team and
individual in their reporting chain. When someone moves teams, their
effective policy changes automatically.

This requires integration with an identity/org-chart source (LDAP,
Rover, or similar). The configuration system must resolve "what is
the effective policy for developer X?" by walking the management chain
upward, merging at each level — analogous to ARC's merge rules but
against a dynamic, people-based hierarchy rather than a static,
repo-based one.

**4. Distribution beyond policy — four content types.**

ARC distributes two things: configuration (how the AI should behave)
and workflows (what steps to follow). Jeremy identifies four distinct
content types that the enterprise harness must distribute:

a. **Policy + governance.** You can do this but not that. Which
   models are approved. What data can enter AI context. What
   security policies apply. This is ARC's `governance.ai.yaml` —
   scaled enterprise-wide.

b. **Plugin marketplaces.** Curated, approved skill/plugin libraries
   — the equivalent of `.claude` files, dotfiles, MCP servers, and
   workflow definitions. Not just "here are the org's skills" but a
   browsable catalog where teams can discover, adopt, and publish
   reusable agent capabilities. Think internal app store for AI
   developer tooling.

c. **Organizational data.** How many people report to XYZ. Is our
   release at risk. Sprint health. Dependencies between teams.
   This is **operational context** — not instructions for the AI,
   but information the AI (and humans) can query to make better
   decisions. ARC doesn't address this at all. It implies MCP
   servers or APIs that expose org data to agents on demand.

d. **Complete audit trail.** ARC's workflow recording is a start
   (who/when/where/what/how/result), but "complete audit trail" at
   enterprise scale means: every AI interaction across every
   developer, searchable, with retention policies, compliance
   tagging, and the ability to answer "what AI-generated code
   shipped in release X?" This is a data platform concern, not a
   file-in-a-repo concern.

### The Tenancy Model

Jeremy's clarification (Mar 2026): the enterprise platform is a
**tenancy abstraction that gives every VP their own harness.** It
does not prescribe what each team's harness looks like — it provides
the isolation, policy inheritance, and shared services so that
multiple harnesses can coexist under a common governance umbrella.

```
Enterprise Platform (tenancy, policy, marketplace, audit)
    ├── Ansible VP's harness  (ARC)
    ├── Dataverse VP's harness (Reins)
    ├── OpenShift VP's harness (their own)
    └── ...every VP gets their own
    │
    └── Optional shared services (e.g., a review API)
```

ARC is not the universal standard. It's the Ansible team's
implementation. The Dataverse team builds Reins. Each team owns
their harness. The enterprise platform provides:

- **Tenancy** — VP-level isolation; each org manages its own
  harness (skills, workflows, config) independently.
- **Policy inheritance** — company-wide policies flow down the
  management chain into each VP's harness. A VP can add policy
  for their org; they cannot remove what's above them.
- **Shared services** — there won't be a single review skill,
  but there could be a single review API (Ambient or otherwise)
  that different review skills call into.
- **Plugin marketplace** — teams can publish skills and workflows
  for others to discover and adopt, without requiring everyone to
  use the same implementation.
- **Audit trail** — unified across all harnesses. The platform
  collects recordings regardless of which team's harness produced
  them.

### Architectural Implication

ARC's design is elegant precisely because it is "not a platform."
But Jeremy's requirements collectively describe one:

- A **management service** with admin UI for policy hierarchy
- An **identity integration** for org-chart-based inheritance
- A **catalog service** for plugin/skill marketplace
- **MCP servers** exposing organizational data to agents
- A **data pipeline** for audit trail ingestion, storage, and query

The convention harness (files in repos, AI reads them) remains the
**delivery mechanism to the developer**. Each team's harness (ARC,
Reins, etc.) operates as a tenant within the enterprise platform,
receiving policy from above and reporting audit data upward.

The key design question becomes: what interface does the enterprise
platform expose to each team's harness? If each VP's harness is
independent, the platform needs a thin contract: "here are your
policies, here are your approved models, here is where you send
recordings." The harness implementation is the team's choice.
This is federated governance, not centralized control.

## Implications for AI-SDLC

The specialized harness pattern maps directly to AI-SDLC's three-loop
workflow. Each loop is a deterministic phase with entry/exit gates:

| AI-SDLC Loop              | Harness Equivalent              |
|---------------------------|---------------------------------|
| Loop 1: Plan              | Phase with dynamic plan + human in the loop |
| Loop 2: Implement + Self-Review | Phase with fixed plan + validation loops |
| Loop 3: Review            | Phase with human approval gate  |

The March of Nines framing strengthens the case for AI-SDLC's
structural enforcement approach: guardrails, coverage thresholds,
and adherence assessments are not optional process overhead — they
are the engineering required to move from 90% to 99%+ reliability.

The sub-agent context isolation pattern is relevant for AI-SDLC's
implementation loop: rather than one monolithic agent generating all
code, the harness could delegate file-level or module-level tasks to
sub-agents with only the relevant context injected.

### Open Question: Artifact Storage for Upstream Specs

Feature specs, ADRs, and decomposition records are important
long-lived artifacts — evidence of why the work was shaped the
way it was. They don't belong in Jira (too structured, poor
versioning, invisible to agents). They also don't naturally belong
in any single implementation repo (a feature may span repos).

ARC solves this with a separate **handbook repo** where SDPs and
tech proposals are committed as PRs, reviewed, and merged. This
has real advantages: versioned history, PR-based review, searchable,
agent-accessible as static context.

For Reins, the current approach stores artifacts in `.reins/` within
the working repo. This works well for story-level artifacts (specs,
plans, reviews) that are scoped to a single repo. For feature-level
artifacts that span repos or outlive any single implementation, a
dedicated documentation repo (or a shared section of a team repo)
may be the better home. Worth revisiting when the upstream planning
skills (feature-spec, decompose) are built.

## Primary Sources

- [My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey#step-5-engineer-the-harness)
  — Mitchell Hashimoto. Step 5 ("Engineer the Harness") introduces the
  harness concept for AI coding agents, predating OpenAI's formal coining.
- [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)
  — Ryan Lopopolo, OpenAI Engineering Blog (Feb 11, 2026). The
  original post. Detailed account of building a product with zero
  manually-written code.
- [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
  — Fowler and Böckeler's analysis. "Harness includes context
  engineering, architectural constraints, and garbage collection."
- [OpenAI Introduces Harness Engineering — InfoQ](https://www.infoq.com/news/2026/02/openai-harness-engineering-codex/)
  — Industry coverage with Fowler's commentary.
- [Harness Engineering: The Complete Guide — NxCode](https://www.nxcode.io/resources/news/harness-engineering-complete-guide-ai-agent-codex-2026)
  — Comprehensive third-party guide with practical framework
  (Level 1/2/3 harness maturity).
- [Harness Engineering: The Developer Skill That Matters — ComputeLeap](https://www.computeleap.com/blog/harness-engineering-developer-skill-2026/)
  — Evidence that major AI labs converged on identical architectures.
- [OpenAI Codex Execution Plans Cookbook](https://cookbook.openai.com/articles/codex_exec_plans)
  — Practical guide for execution plans as first-class artifacts.
- [5 Skills Every AI Agent Needs (And Why Your Mega-Prompt Is Holding You Back)](https://medium.com/@Micheal-Lanham/5-skills-every-ai-agent-needs-and-why-your-mega-prompt-is-holding-you-back-4b4ab2471c0e)
  — Micheal Lanham (Feb 27, 2026). Skills as a delivery mechanism for
  harness constraints. Progressive disclosure model, cross-framework
  portability, security concerns (26% of skills contain vulnerability
  patterns). Skills are a channel for the harness, not a separate concept.
- [Andrej Karpathy's Math Proves Agent Skills Will Fail. Here's What to Build Instead](https://www.youtube.com/watch?v=I2K81s0OQto)
  — The AI Automators (Mar 21, 2026). Practical demo of a specialized
  contract review harness. Covers March of Nines reliability framing,
  sub-agent context isolation, model routing, state management, and
  12 design considerations for agent harnesses.
- [Master 95% of Claude Code Agent Teams in 16 Mins](https://www.youtube.com/watch?v=vDVSGVpB2vc)
  — Nate Herk (Mar 23, 2026). Practical walkthrough of Claude Code's
  agent teams feature. Covers team setup, prompting patterns (goal →
  roles → communication flow → deliverables), agent teams vs.
  sub-agents, file ownership, plan approval mode, tmux visibility,
  clean shutdown protocol, and when to use teams vs. sub-agents.
- **ARC: Rethinking the SDLC for the Age of AI-Assisted Development**
  — Ansible team internal presentation (Mar 2026). Executive pitch
  for a CLI-agnostic hierarchical configuration and workflow
  framework (ARC = Agent Runtime Configuration). Four-level hierarchy
  (org/team/repo/user), `governance.ai.yaml` for locked constraints,
  14 SDLC workflows with entry/exit gates and automatic recording,
  Makefile-based distribution. Proposes a 30-day pilot on one team
  with an existing codebase.
  Source: `arc-executive-presentation.pdf`
