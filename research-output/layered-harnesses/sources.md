# Layered Harnesses: Source Assessments

Raw source evaluations from Phase 3 (subagent assessments) and
Phase 4 (inline follow-up assessments).

---

## Batch 1: Core Harness Architecture Sources

### Zylos Research — Agent Harness Design Patterns
- **URL:** https://zylos.ai/research/2026-03-31-agent-harness-design-patterns
- **Relevance:** 6/10 (layered), 9/10 (harness general)
- **Type:** Vendor research / engineering-blog
- **Key claims:**
  - [FACT] LangChain Terminal Bench: 52.8% → 66.5%, rank 30→5,
    harness-only changes
  - [CLAIM] "Agent = Model + Harness"; six canonical areas
  - [CLAIM] Vercel text-to-SQL: 80%→100% success, 3.5x speed,
    ~37% fewer tokens after tool reduction
  - [OPINION] "Model is commodity, harness is moat"
- **Layer coverage:** Treats harness as single layer. Hints at
  supervisor pattern ("Principal Skinner over Ralph loop") that
  maps to workflow layer.

### Pappas — The Agent Harness Is the Architecture
- **URL:** https://medium.com/@epappas/the-agent-harness-is-the-architecture-and-your-model-is-not-the-bottleneck-5ae5fd067bb2
- **Relevance:** 5/10 (layered), 9/10 (harness-beats-model)
- **Type:** Engineering-blog
- **Key claims:**
  - [FACT] APEX-Agents (Mercor): pass@1 ~24%, pass@8 ~40%
  - [FACT] Vercel d0 restructuring: 15 tools → 2
  - [CLAIM] Above capability floor, harness dominates reliability
  - [OPINION] "Harness is the OS"; "build for deletion"
- **Layer coverage:** Single harness layer. Maps to runtime tier.

### Taskos — The Stack Is Settled
- **URL:** https://medium.com/@georgetaskos/the-stack-is-settled-the-agentic-layer-cake-has-crystallized-fe3499635692
- **Relevance:** 9/10 (layered)
- **Type:** Opinion / engineering-blog
- **Key claims:**
  - [CLAIM] Three-layer stack: orchestration / runtime-infra /
    protocol (closest to runtime vs workflow split)
  - [CLAIM] LangGraph offers durable execution, HITL interrupt
    nodes (deterministic gates)
  - [CLAIM] AgentCore: session isolation, memory, tool gateway,
    observability
  - [OPINION] "Framework wars were the wrong fight"; "know which
    layer your problem lives in"
- **Layer coverage:** Strongest explicit layering among all sources.

---

## Batch 2: Architecture & Stack Sources

### harness-engineering.ai — How the System Works Under the Hood
- **URL:** https://harness-engineering.ai/blog/agent-harness-architecture-how-the-system-works-under-the-hood/
- **Relevance:** 8/10
- **Type:** Engineering-blog
- **Key claims:**
  - [FACT] Five-layer harness: orchestration, context, tools,
    verification, operations
  - [FACT] Anthropic definition cited for harness
  - [OPINION] "Harness does more work than the model on every task"
  - [CLAIM] Frameworks help layers 1-3; layers 4-5 require custom
    implementation
- **Layer coverage:** Good runtime detail. Verification and ops
  touch workflow concerns.

### Tacnode — The AI Agent Stack in 2026
- **URL:** https://tacnode.io/post/the-ideal-stack-for-ai-agents-in-2026
- **Relevance:** 6/10
- **Type:** Engineering-blog / vendor positioning
- **Key claims:**
  - [CLAIM] Six-layer stack: context, retrieval, reasoning,
    tooling, orchestration, observability
  - [OPINION] "Agent reliability is a systems problem, not a
    model problem"
  - [FACT] Orchestration includes agent loop, state persistence,
    retries, multi-agent coordination
- **Layer coverage:** Focuses on runtime concerns. No explicit
  workflow layer.

### Fahey — The Sixth Layer of the AI Stack
- **URL:** https://medium.com/@fahey_james/the-sixth-layer-of-the-ai-stack-orchestration-agents-and-the-coordination-economy-db5685f2e5cb
- **Relevance:** 5/10
- **Type:** Opinion
- **Key claims:**
  - [CLAIM] Five-layer AI industry stack plus sixth "orchestration
    and coordination" layer
  - [OPINION] Intelligence emerges from networks, not single models
  - [OPINION] "Coordination economy" — value shifts to
    orchestration owners
- **Layer coverage:** Strategic/market framing. Not technically
  detailed enough for architecture split.

---

## Batch 3: Workflow & Enterprise Sources

### Codegen — How to Build Agentic Coding Workflows
- **URL:** https://codegen.com/blog/how-to-build-agentic-coding-workflows/
- **Relevance:** 6/10
- **Type:** Vendor blog
- **Key claims:**
  - [FACT] GitHub research: developers gaining more from AI spent
    more time structuring requests
  - [CLAIM] Main failure mode is underspecified context/inputs
  - [CLAIM] Architecture: task input → context → sandbox →
    PR → review (AI + human)
  - [OPINION] "The fix isn't more powerful agents. It's better
    inputs."
- **Layer coverage:** Describes workflow-like pipeline but doesn't
  frame it architecturally.

### Camunda — Agentic Orchestration
- **URL:** https://camunda.com/agentic-orchestration/
- **Relevance:** 9/10
- **Type:** Vendor docs
- **Key claims:**
  - [CLAIM] Agents without orchestration lack coordination,
    accountability, reliability
  - [FACT] "State of Agentic Orchestration 2026" — 1,150 senior
    IT leaders surveyed (vendor-reported)
  - [CLAIM] BPMN + agents: deterministic flows for predictability,
    agents where reasoning adds value
  - [CLAIM] MCP and A2A connectors with process instance
    correlation
  - [OPINION] Process orchestration is foundation; agentic
    orchestration adds governed AI
- **Layer coverage:** Strongest workflow-harness source. Explicitly
  separates deterministic process from agentic execution.

### Masood — State of Agent Frameworks
- **URL:** https://medium.com/@adnanmasood/state-of-agent-frameworks-choosing-the-right-runtime-for-enterprise-ai-execution-cc69653ffb10
- **Relevance:** 7/10 (preview only — paywalled)
- **Type:** Opinion / engineering-blog
- **Key claims (from preview):**
  - [CLAIM] Market beyond "prompt wrappers"; differentiation is
    runtime control
  - [CLAIM] LangGraph vs LangChain: flexible abstraction vs
    low-level control
  - [CLAIM] MS Agent Framework and Google ADK emphasize workflow
    control, multi-agent composition

---

## Batch 4: Runtime & Control Sources

### harness-engineering.ai — What Is Harness Engineering?
- **URL:** https://harness-engineering.ai/blog/what-is-harness-engineering/
- **Relevance:** 6/10
- **Type:** Engineering-blog
- **Key claims:**
  - [FACT] APEX-Agents pass rate ~24%; LangChain 52.8%→66.5%
  - [CLAIM] "Harness is the 80% factor"
  - [CLAIM] Verification loops: ~83%→~96% without model/prompt
    change
  - [OPINION] Prompt/context/harness should not be conflated
- **Layer coverage:** Single harness layer. Good depth on runtime.

### ezefaz — Orchestrating AI Coding Agents in 2026
- **URL:** https://ezefaz.com/en/blog/orchestrating-ai-coding-agents-2026
- **Relevance:** 2/10
- **Type:** Practitioner guide
- **Key claims:**
  - [CLAIM] "90% of Claude Code code written by AI" (needs
    primary verification)
  - [OPINION] "Orchestration is the edge" / process beats tools
  - [FACT] Describes AGENTS.md, skills, specs as consistency
    mechanisms
- **Layer coverage:** Human workflow, not system architecture.

### htek.dev — Agent Harnesses: Controlling AI Agents
- **URL:** https://htek.dev/articles/agent-harnesses-controlling-ai-agents-2026
- **Relevance:** 8/10
- **Type:** Engineering-blog
- **Key claims:**
  - [FACT] Concrete loop design: per-iteration checks, budgets,
    compaction, output inspection, tool validation
  - [CLAIM] Frameworks / runtimes / harnesses taxonomy
  - [FACT] Describes post-loop: "post-guardrails, compliance rules,
    review gate" — bridge to workflow layer
  - [OPINION] "Agents without harnesses are prototypes"
- **Layer coverage:** Strongest on runtime loop ownership. Partial
  bridge to workflow via final gates.

---

## Phase 4: Follow-Up Sources (Inline Assessment)

### Anthropic — Effective Harnesses for Long-Running Agents
- **URL:** https://anthropic.com/engineering/effective-harnesses-for-long-running-agents
- **Relevance:** 9/10
- **Type:** Primary vendor docs (Anthropic engineering)
- **Key claims:**
  - [FACT] Two-agent harness: initializer + coding agent
  - [FACT] Feature list as JSON (200+ features for claude.ai clone)
  - [FACT] claude-progress.txt + git history as cross-session state
  - [FACT] Prompt differentiation only — same tools, same harness
  - [CLAIM] Incremental single-feature progress + clean state is
    critical
- **Layer coverage:** Deep Layer 1 (runtime). No Layer 2 (workflow
  engine). Process encoded entirely in prompts.

### OpenAI — Harness Engineering: Leveraging Codex
- **URL:** https://openai.com/index/harness-engineering/
- **Relevance:** 9/10
- **Type:** Primary vendor docs (OpenAI engineering)
- **Key claims:**
  - [FACT] 1M+ lines, 0 manually written, ~1,500 PRs, 3.5
    PRs/engineer/day
  - [FACT] AGENTS.md as table of contents, docs/ as system of
    record
  - [FACT] Execution plans as versioned artifacts in repo
  - [FACT] Custom linters enforcing architectural constraints
  - [FACT] "Ralph Wiggum Loop" — agent reviews own PR, requests
    additional agent reviews, iterates until satisfied
  - [CLAIM] "Context management is one of the biggest challenges"
  - [OPINION] "Building software still demands discipline, but the
    discipline shows up more in the scaffolding rather than the
    code"
- **Layer coverage:** Hybrid — repo-as-workflow. Layer 1 + some
  Layer 2 concepts (plans, linters, review loops) but no external
  workflow engine.

### Temporal — AI Agent Support
- **URL:** https://temporal.io/ai + related blog posts
- **Relevance:** 8/10
- **Type:** Vendor docs (Temporal)
- **Key claims:**
  - [FACT] Deterministic workflow code, non-deterministic activities
  - [FACT] Durable execution: survives crashes, replays from
    event history
  - [FACT] Supports agent routing, task delegation, HITL
  - [CLAIM] "Temporal is ideal for dynamic AI agents that don't
    follow predetermined paths"
- **Layer coverage:** Cleanest Layer 2 architecture. Explicit
  separation of deterministic orchestration from non-deterministic
  agent execution.

### Camunda — Agentic Orchestration (deep fetch)
- **URL:** https://camunda.com/agentic-orchestration/
- **Relevance:** 9/10
- **Type:** Vendor docs (Camunda)
- **Key claims:**
  - [CLAIM] BPMN process as foundation, agents as tasks within
  - [FACT] Integrates with LangChain; MCP + A2A connectors
  - [CLAIM] "Multi-layer architecture" — BPMN + SDKs + agents
  - [FACT] Survey: 1,150 senior IT leaders (vendor-reported)
- **Layer coverage:** Strongest workflow-layer source. BPMN =
  deterministic Layer 2; agents = non-deterministic Layer 1.
