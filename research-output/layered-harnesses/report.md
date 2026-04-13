# Layered Harnesses: Runtime vs Workflow Orchestration in AI Agent Architecture

*Generated: 2026-04-13 | Sources: 18 | Search queries: 11*

---

## Executive Summary

- The AI agent ecosystem in 2026 treats "harness" as a single concept,
  but production systems reveal **two distinct architectural layers**:
  a **runtime harness** (managing the LLM loop, context window, tools,
  compaction) and a **workflow harness** (enforcing deterministic
  process gates, compliance, artifact trails, human checkpoints above
  the runtime).
- No major source explicitly names this split using "runtime harness"
  vs "workflow harness" vocabulary. The closest are Taskos's
  three-layer stack (orchestration / runtime-infra / protocol) [2],
  Camunda's "deterministic process with agentic flexibility" [12],
  and Temporal's "deterministic workflow code wrapping
  non-deterministic agent decisions" [15].
- Primary sources from Anthropic [9], OpenAI [10], and LangChain [1]
  focus almost exclusively on Layer 1 (the runtime harness). The
  workflow layer is treated as either "prompt engineering" or left to
  the user. This is the gap that systems like Reins, Camunda, and
  Temporal fill.
- The industry consensus that "harness > model" (supported by
  LangChain's 52.8% → 66.5% benchmark improvement from harness
  changes alone [1], Vercel's 80% → 100% accuracy from tool reduction
  [3], and OpenAI's 10x development speed claim [10]) applies
  primarily to Layer 1. Layer 2's value proposition is different:
  it's about **process guarantees** over a non-deterministic engine,
  not about making the engine perform better.
- The sharpest framing comes from Temporal: workflow code must be
  deterministic, but the activities it orchestrates (LLM calls, tool
  use) can be fully non-deterministic [15]. This maps cleanly to:
  Layer 2 (deterministic workflow) orchestrates Layer 1
  (non-deterministic agent runtime).

---

## Current Landscape

### The Single-Harness View (Dominant Narrative)

Most 2026 writing on agent harnesses treats the harness as **one
layer** wrapping the model. The canonical definition, attributed to
Anthropic and echoed across sources:

> An agent harness is the operational structure for models working
> across multiple context windows on extended tasks. [5, 9]

The standard component list (per Zylos Research [1], harness-
engineering.ai [5], and htek.dev [7]):

| Component          | Function                                    |
|--------------------|---------------------------------------------|
| Orchestration      | Execution loop, step budgets, routing       |
| Context management | Compaction, resets, tool output offloading   |
| Tool integration   | Sandboxed execution, MCP, external APIs     |
| Verification       | Output validation, test execution           |
| Operations         | Observability, cost control, error recovery |

This is the view Harrison Chase presents in his MAD Podcast
interview [18], where "harness" encompasses system prompts, planning
tools, sub-agents, and file systems — all as one conceptual layer.

### The Layered View (Emerging)

Several sources describe or imply a separation, even if they don't
use the "two-layer harness" label:

**Taskos (Medium, March 2026) [2]** — the most explicit stack
separation:

| Layer | Concern | Examples |
|-------|---------|----------|
| Orchestration | Graphs, branching, HITL interrupts, compliance | LangGraph, CrewAI Flows |
| Runtime/Infra | Sessions, memory, observability, audit | AWS Bedrock AgentCore, LangSmith |
| Protocol | Tool connectivity, agent interoperability | MCP, A2A |

**Camunda [12]** — explicitly contrasts deterministic process
control (BPMN gateways, long-running process instances) with agentic
behavior (planning loops, memory, tools). Agents are embedded as
tasks within BPMN; the process model enforces gates:

> "Process orchestration is the foundation; agentic orchestration
> adds governed AI into the same model — process-level determinism
> with agentic flexibility." [12]

**Temporal [15]** — the clearest architectural separation:
deterministic workflow code orchestrates non-deterministic activities:

> "While Temporal requires deterministic workflow code (orchestration
> layer), the actual agent decisions can be completely
> non-deterministic based on LLM outputs. Activities — where actual
> work happens (LLM calls, tool invocation) — can be as unpredictable
> as needed." [15]

**A2A / MCP three-layer stack (dev.to, 2026) [17]**:

1. Tool-and-context plane (MCP)
2. Agent-interoperability plane (A2A)
3. Control plane (orchestration): routing, retry, escalation,
   compliance, observability

**Hendawy (Medium, April 2026) [17]** — nesting model:

- Prompt engineering → Context engineering → **Harness engineering**
- Each layer subsumes the previous; the outermost (harness) is
  "constraints, feedback loops, operational systems outside the
  agent"

### Framework Positioning

| Framework/Tool | Primary Layer | Notes |
|---------------|---------------|-------|
| Claude Agent SDK | Runtime | Loop, compaction, tools, sub-agents [9] |
| Claude Code | Runtime + UI | Harness + developer interface [18] |
| OpenAI Codex | Runtime | Sandbox, tool execution, context [10] |
| LangGraph 2.0 | Runtime | Durable execution, state, streaming [6] |
| Deep Agents | Runtime | Planning, file system, skills, sub-agents [18] |
| LangChain 1.0 | Runtime (thin) | `create_agent` = LLM loop + tools [18] |
| CrewAI Flows | Workflow | Business process orchestration [6] |
| Camunda | Workflow | BPMN-based, deterministic gates [12] |
| Temporal | Workflow | Durable workflows, deterministic orchestration [15] |
| Orcaworks | Workflow | Declarative governed agent execution [11] |
| IBM watsonx | Workflow | Multi-agent orchestration, policy enforcement [11] |
| **Reins** | **Workflow** | **Deterministic SDLC: plan → implement → review → fix** |

---

## The Two Layers Defined

Based on synthesis across all sources, here is a proposed taxonomy:

### Layer 1: Runtime Harness

**Owns:** The LLM interaction loop and its immediate environment.

**Answers:** *How does the model interact with its environment?*

**Components:**
- Tool-calling loop (observe → reason → act → observe)
- Context window management (compaction, summarization, resets)
- File system access (read/write, offloading large results)
- Sub-agent spawning and context isolation
- Prompt caching and streaming
- Code execution and sandboxing
- Token-level optimization (prompt caching, output truncation)

**Key property:** Non-deterministic. The model decides what to do
next; the harness provides the environment and guardrails for each
step.

**Evidence for this layer being well-understood:**
- Anthropic's two-agent and three-agent harness designs [9, 4]
- OpenAI's Codex harness (AGENTS.md, execution plans, linters) [10]
- LangChain's benchmark improvements from harness-only changes [1]
- Harrison Chase's "four primitives" (prompt, planning, sub-agents,
  file system) [18]

### Layer 2: Workflow Harness

**Owns:** The process that orchestrates agent sessions toward a
defined outcome.

**Answers:** *What should the model accomplish, in what order, with
what quality gates?*

**Components:**
- Phase sequencing (plan → approve → implement → review → fix)
- Human checkpoints (approval gates, review gates)
- Artifact management (specs, plans, reviews as persistent records)
- Compliance enforcement (guardrails that cannot be overridden)
- Cross-session state (a plan from session 1 feeds implementation
  in session 2)
- Deterministic transitions (if review fails → fix; if fix
  exceeds rounds → escalate)
- Audit trails (every phase produces traceable artifacts)

**Key property:** Deterministic. The workflow defines what happens
next; the agent provides the horsepower within each phase.

**Evidence this layer is under-theorized:**
- Most sources treat it as "just use a good prompt" (Chase [18]:
  "for better or worse, the way you get these things to do anything
  is you just tell them to do it")
- Anthropic's two-agent harness uses prompts to separate initializer
  from coder [9], but has no formal state machine or gate logic
- OpenAI's Codex relies on repo-embedded knowledge and linters [10],
  not an external workflow engine
- The enterprise platforms (Camunda [12], Temporal [15], Orcaworks
  [11]) recognize this gap and fill it, but they come from the BPM
  world, not the AI-native world

---

## Why the Distinction Matters

### Different Failure Modes

Layer 1 failures are about the agent performing poorly within a
task:
- Context overflow / "context rot" [1, 5]
- Hallucinated tool calls [5]
- Premature task completion [9]
- Poor sub-agent communication [18]

Layer 2 failures are about the process failing to produce the right
outcome:
- Agent implements without an approved plan
- No review before merge
- Compliance requirements skipped
- No artifact trail for audit
- Agent drifts from the original story scope

These failure modes require different solutions. You can't fix
Layer 2 problems by improving the runtime harness — you need
deterministic process control above it.

### Different Stability Profiles

Harrison Chase observes [18] that the harness primitives (loop +
tools + file system + code execution) are stabilizing, while the
scaffolding changes weekly. This stability claim applies to Layer 1.

Layer 2 is inherently more stable because it encodes **process
knowledge**, not model interaction patterns:
- "Plan before implement" doesn't change when models improve
- "Human approves the plan" is a business decision, not a
  technical workaround
- "Every PR gets a review" is a quality standard, not a model
  limitation

### Different Portability Characteristics

Layer 1 is tied to a specific runtime (Claude Code, Cursor, Codex).
Layer 2 should be portable across runtimes.

Reins demonstrates this: the same skills and workflow work on Claude
Code and Cursor because Reins operates at Layer 2 — it doesn't
care about compaction strategies or prompt caching.

---

## Industry Patterns & Best Practices

### Pattern 1: Prompt-as-Workflow (Dominant, AI-Native)

Both Anthropic [9] and OpenAI [10] encode workflow logic into
prompts and repo artifacts rather than external workflow engines:

- Anthropic's initializer/coder agent split is controlled by
  different user prompts, not a state machine
- OpenAI's execution plans are markdown files in the repo; agents
  read and update them, but nothing enforces the sequence

**Strengths:** Simple, no external dependencies, flexible.
**Weaknesses:** No enforcement guarantees, relies on model
compliance, no formal audit trail, difficult to add human gates.

### Pattern 2: Harness-Internal Orchestration (Growing)

LangGraph 2.0 [6] and CrewAI Flows [6] build orchestration into
the agent framework:
- LangGraph: directed cyclic graphs with conditional edges, HITL
  interrupt nodes, checkpoint persistence
- CrewAI: "Crews" (autonomous agent teams) composed into "Flows"
  (deterministic business processes)

**Strengths:** Tight integration, single framework.
**Weaknesses:** Coupled to a specific agent framework, may not
survive framework volatility (Chase himself acknowledges three
LangChain-family frameworks "should show you how volatile it
is" [18]).

### Pattern 3: External Workflow Engine (Enterprise)

Camunda [12], Temporal [15], IBM watsonx [11], Orcaworks [11]:
- Deterministic workflow engine is a separate system
- Agent runtimes are invoked as activities/tasks
- Gates, approvals, compliance are in the workflow, not the agent

**Strengths:** Separation of concerns, mature governance, survives
agent framework changes.
**Weaknesses:** Integration complexity, additional infrastructure,
may feel heavy for small teams.

### Pattern 4: Skills-as-Workflow (Reins Model)

Encode workflow phases as skills that a runtime-agnostic agent
consumes:
- Each phase (plan, implement, review, fix) is a self-contained
  skill with instructions
- Transitions are either human-triggered (plan → approve →
  implement) or chained (implement → review → fix)
- Artifacts in `.reins/` provide the audit trail
- Works on any runtime that supports skill loading

**Strengths:** Lightweight, portable, no external engine needed,
progressive — start simple, add gates as needed.
**Weaknesses:** Enforcement is "soft" (prompt-based within skills),
transitions between skills rely on the human or a meta-workflow.

---

## Opinions & Debate

### "The Harness Is All You Need" vs "You Need Layers"

The dominant 2026 narrative is that a good runtime harness is
sufficient:

> "Simpler harnesses plus better models beat complex orchestration."
> — Pappas [3], synthesizing signals from OpenAI, Anthropic, and
> Meta/Manus

This view is supported by impressive results (OpenAI's million-line
codebase [10], Anthropic's multi-hour autonomous sessions [9,4]).

The counter-argument, primarily from the enterprise/BPM world:

> "Agents without orchestration lack coordination, accountability,
> and reliability for business-critical processes." — Camunda [12]

> "The orchestration layer is where most production pain actually
> lives — it provides operational discipline beyond mere
> connectivity." — dev.to A2A analysis [17]

The resolution may be that **both are right at their respective
layers**: the runtime harness is sufficient for individual agent
sessions, but you need a workflow harness for multi-session, multi-
stakeholder processes with compliance requirements.

### "Models Will Eat the Harness" vs "The Harness Is the Moat"

Chase [18]: "I don't know what will happen but the harness is
really important."

Pappas [3]: "Build for deletion — as models improve, harness
components should be designed to be removed."

htek.dev [7]: "Agents without harnesses are prototypes."

The nuance: "build for deletion" advice applies to Layer 1 (as
models get better at context management, compaction may become
unnecessary). Layer 2 is unlikely to be eaten by models because
it encodes **organizational process**, not model compensations.

---

## Where Things Are Headed

### Convergence Signals

1. **Runtime harness commoditization** — Chase's "four primitives"
   are converging across all frameworks [18]. Deep Agents, Claude
   Code, and Codex all have loop + tools + files + sub-agents.
   Differentiation at Layer 1 is shrinking.

2. **Workflow harness emergence** — CrewAI adding "Flows" [6],
   Camunda adding "agentic orchestration" [12], Temporal adding
   "AI agent" support [15], and Orcaworks launching an "agentic
   automation platform" [11] all signal that the industry recognizes
   the need for a Layer 2.

3. **Agent self-compaction as tool** — Chase describes giving agents
   a tool to trigger their own compaction [18]; Anthropic's planner-
   generator-evaluator pattern has agents managing their own multi-
   session state [4]. This pushes more Layer 1 responsibility into
   the model itself, potentially simplifying the runtime harness.

4. **Procedural memory as the bridge** — Chase's concept of
   procedural memory (instructions/skills the agent can modify) [18]
   sits at the boundary between layers. The runtime provides the
   mechanism (file system); the workflow decides when modification
   is appropriate (e.g., after a retro, not mid-implementation).

### Predictions

- By late 2026, major agent frameworks will explicitly separate
  "runtime" and "workflow" concerns in their architecture, rather
  than conflating them under "harness" or "orchestration."
- Enterprise adoption will drive this split — regulated industries
  (Chase's LangGraph market [18]) need deterministic workflow
  guarantees that runtime harnesses don't provide.
- The "skills-as-workflow" pattern (encoding process as portable
  skill files rather than a separate engine) will gain traction in
  developer-facing tools, while BPMN-based approaches dominate
  enterprise/business process use cases.

---

## Technical Deep-Dives

### Anthropic: From Two-Agent to Three-Agent Harness

Anthropic's evolution is instructive for understanding Layer 1:

**Two-agent harness (November 2025) [9]:**
- Initializer agent: scaffolds environment, writes feature list
- Coding agent: incremental progress, clean state, git commits
- Key artifact: `claude-progress.txt` + git history
- Controlled by prompt differentiation, not a state machine

**Three-agent harness (March 2026) [4]:**
- Planner: decomposes specs into discrete chunks
- Generator: builds code within one context window
- Evaluator: grades output against predefined criteria
- Uses **hard context resets** between agents (not compaction)

The three-agent design is notable because it introduces a
**separation of concerns** within Layer 1 that mirrors what
Layer 2 does at a higher level: plan, execute, verify.
But it's still within one session — it doesn't enforce
cross-session process (e.g., "a human must approve the plan
before the generator runs").

### OpenAI: Repository as the Harness

OpenAI's Codex approach [10] is the most aggressive encoding
of harness-as-repo:

- `AGENTS.md` as table of contents, not encyclopedia
- `docs/` directory as system of record
- Execution plans as versioned artifacts
- Custom linters enforcing architectural constraints
- "Doc-gardening" agent for keeping knowledge current
- "Golden principles" encoded in repo, enforced by CI

Key metric: 1 million+ lines of code, 0 manually written,
~1,500 PRs merged, 3.5 PRs/engineer/day.

This approach encodes some Layer 2 concepts (plans as
artifacts, architectural enforcement) but does so within the
repo rather than in an external workflow engine. It's a hybrid:
the repo itself becomes both the runtime context and the
workflow memory.

### Temporal: The Cleanest Layer Separation

Temporal's architecture [15] provides the sharpest conceptual
model:

```
┌──────────────────────────────────────┐
│  Workflow (deterministic)            │
│  ┌─────────────┐ ┌─────────────┐    │
│  │ Plan phase  │→│ Gate: human │─┐  │
│  └─────────────┘ │   approval  │ │  │
│                   └─────────────┘ │  │
│  ┌─────────────┐                  │  │
│  │ Implement   │←─────────────────┘  │
│  │  phase      │                     │
│  └──────┬──────┘                     │
│         ↓                            │
│  ┌─────────────┐ ┌─────────────┐    │
│  │ Review phase│→│ Gate: pass/ │    │
│  └─────────────┘ │   fail      │    │
│                   └─────────────┘    │
└──────────────────────────────────────┘
         ↕ (activities)
┌──────────────────────────────────────┐
│  Agent Runtime (non-deterministic)   │
│  LLM loop, tools, compaction,        │
│  sub-agents, file system             │
└──────────────────────────────────────┘
```

The workflow code is deterministic and durable — it survives
crashes, replays from event history, and persists state across
hours/days/months. The agent activities within each phase are
non-deterministic — they can call LLMs, use tools, and produce
unpredictable outputs. The workflow doesn't care *how* the
agent works, only *what* it produces and *whether* it meets
the gate criteria.

---

## Key Trends

1. **"Harness > Model" is Layer 1 consensus** — supported by
   LangChain benchmarks [1], Vercel metrics [3], OpenAI's
   development velocity [10], and Anthropic's session management
   [9]. At least 5 independent sources confirm this.

2. **Runtime harness primitives are converging** — loop + tools +
   file system + sub-agents + compaction. Every major player has
   these. Differentiation is moving elsewhere. (Chase [18],
   Zylos [1], htek.dev [7])

3. **Enterprise workflow layer is crystallizing** — Camunda [12],
   Temporal [15], IBM [11], Orcaworks [11], and CrewAI Flows [6]
   all launched or expanded agentic workflow capabilities in
   2025-2026. The enterprise demand for deterministic process
   control above agents is validated.

4. **Skills/instructions as the durable investment** — Chase's
   advice [18], OpenAI's repo-as-system-of-record approach [10],
   and Anthropic's prompt-driven agent differentiation [9] all
   converge on: the most portable and valuable asset is the
   process knowledge encoded in instructions/skills/docs, not the
   framework or runtime.

---

## Evidence Gaps & Open Questions

1. **No source explicitly names the two-layer split.** The "runtime
   harness" vs "workflow harness" taxonomy proposed in this report
   is a synthesis, not a direct citation. The industry may converge
   on different terminology.

2. **Limited benchmarks for Layer 2 value.** While Layer 1 has
   concrete metrics (LangChain's 14-point improvement, Vercel's
   100% accuracy, OpenAI's 10x speed), there are no published
   benchmarks showing the impact of adding a workflow layer above
   a runtime harness. The value proposition is argued from first
   principles (compliance, audit, process guarantee) rather than
   measured.

3. **Prompt-as-workflow durability is unknown.** Anthropic [9] and
   OpenAI [10] achieve impressive results encoding workflow logic
   in prompts and repo artifacts. Whether this breaks down at
   organizational scale (many teams, regulated industries, long
   audit trails) hasn't been publicly documented.

4. **Layer 2 overhead not quantified.** Adding a workflow engine
   (Camunda, Temporal) introduces infrastructure and latency. No
   source compares total system cost (including governance and
   audit value) of workflow-engine approaches vs prompt-based
   approaches.

5. **The "soft enforcement" gap.** Systems like Reins that encode
   workflow as skills rely on the model following instructions.
   Hard enforcement (as in Temporal or Camunda) requires an
   external engine. The tradeoff between portability and
   enforcement strength is not well-characterized.

---

## Sources

1. [Agent Harness Design Patterns — Zylos Research](https://zylos.ai/research/2026-03-31-agent-harness-design-patterns) — vendor research
2. [The Stack Is Settled — George Taskos (Medium)](https://medium.com/@georgetaskos/the-stack-is-settled-the-agentic-layer-cake-has-crystallized-fe3499635692) — opinion/engineering-blog
3. [The Agent Harness Is the Architecture — Evangelos Pappas (Medium)](https://medium.com/@epappas/the-agent-harness-is-the-architecture-and-your-model-is-not-the-bottleneck-5ae5fd067bb2) — engineering-blog
4. [Harness Design for Long-Running Application Development — Anthropic](https://www.anthropic.com/engineering/harness-design-long-running-apps) — vendor-docs
5. [Agent Harness Architecture: How the System Works Under the Hood — harness-engineering.ai](https://harness-engineering.ai/blog/agent-harness-architecture-how-the-system-works-under-the-hood/) — engineering-blog
6. [Agentic AI Frameworks 2026: LangGraph vs CrewAI vs AutoGen — agent-harness.ai](https://agent-harness.ai/blog/agentic-ai-frameworks-2026-langgraph-vs-crewai-vs-autogen-vs-openai-symphony/) — comparison
7. [Agent Harnesses: Why 2026 Isn't About More Agents — htek.dev](https://htek.dev/articles/agent-harnesses-controlling-ai-agents-2026) — engineering-blog
8. [AI Agent Orchestration Best Practices — ai-agentsplus.com](https://www.ai-agentsplus.com/blog/ai-agent-orchestration-best-practices-march-2026) — tutorial
9. [Effective Harnesses for Long-Running Agents — Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — vendor-docs (primary)
10. [Harness Engineering: Leveraging Codex — OpenAI](https://openai.com/index/harness-engineering/) — vendor-docs (primary)
11. [Agentic Automation Platform — Orcaworks](https://orcaworks.ai/agentic-automation-platform/) + [IBM watsonx Orchestrate](https://www.ibm.com/products/watsonx-orchestrate) — vendor-docs
12. [Agentic Orchestration — Camunda](https://camunda.com/agentic-orchestration/) — vendor-docs
13. [The Complete AI Agent Stack in 2026 — Optijara](https://www.optijara.ai/en/blog/ai-agent-stack-2026-complete-guide) — overview
14. [How to Build Agentic Coding Workflows — Codegen](https://codegen.com/blog/how-to-build-agentic-coding-workflows/) — vendor-blog
15. [Temporal for AI](https://temporal.io/ai) + [Durable Multi-Agentic Architecture](https://temporal.io/blog/using-multi-agent-architectures-with-temporal) + [Dynamic AI Agents with Temporal](https://temporal.io/blog/of-course-you-can-build-dynamic-ai-agents-with-temporal) — vendor-docs
16. [The AI Agent Stack in 2026: 6 Layers — Tacnode](https://tacnode.io/post/the-ideal-stack-for-ai-agents-in-2026) — engineering-blog
17. [A2A Is Not MCP: Enterprise Agent Stack — dev.to](https://dev.to/chunxiaoxx/a2a-is-not-mcp-the-2026-enterprise-agent-stack-needs-both-plus-orchestration-2h0h) + [From Prompts to Harnesses — Hendawy (Medium)](https://medium.com/@mohamed-hendawy/from-prompts-to-harnesses-the-three-eras-of-ai-agent-engineering-fbd0e6168b21) — engineering-blog
18. [Everything Gets Rebuilt: The New AI Agent Stack — Harrison Chase, MAD Podcast](https://www.youtube.com/watch?v=rSKh6bVuVZI) — interview (primary)
