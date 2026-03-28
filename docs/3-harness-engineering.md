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

2. **Agent-to-agent review.** OpenAI pushes almost all review to
   agent-to-agent. AI-SDLC's Loop 3 is human review. The harness
   engineering model suggests agent review as the norm, with human
   review as escalation. Claude Code agent teams make this concrete:
   a QA teammate with fresh context reviewing developer agents' work
   before the human ever sees it.

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
