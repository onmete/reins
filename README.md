<p align="center">
  <img src="docs/assets/reins_header.jpg" alt="Reins — human holding the reins on an AI horse" width="100%" />
</p>

# Reins

A deterministic backend that drives AI agent runtimes through a
multi-loop software development workflow. Write a story, and Reins
plans it, implements it, self-reviews it, and opens a PR — with human
approval at the design stage, not the implementation stage.

## The Problem

Most teams adopt AI coding tools by inserting them into existing
workflows: write code faster, generate tests faster, review faster.
This produces more volume at the same cognitive cost — or worse,
increases cognitive load without changing how value is delivered.

## The Approach

Shift the engineer's role from **implementer** to **supervisor**.
Define what needs to happen (story + acceptance criteria), evaluate
whether it happened correctly (adherence review), and decide what to
do next. The implementation is delegated to AI agents operating
within well-defined boundaries.

```
reins run STORY-1
  → reads story from .reins/stories/STORY-1.md
  → generates implementation plan (agent, read-only)
  → prints plan, waits for approval
  → implements code (agent, edit+execute)
  → self-reviews against acceptance criteria (agent, read-only)
  → creates PR with adherence report
```

The backend drives every transition deterministically. The agent
executes focused tasks per phase with isolated context windows.

## Key Principles

1. **Plan before execution** — no code is generated until the
   approach is agreed
2. **Backend drives, agent executes** — the state machine controls
   workflow, not the LLM
3. **Structural enforcement over individual discipline** — gates
   are baked into the system, not left to the engineer's judgment
4. **Phase isolation** — each agent invocation gets focused context
   and scoped tools
5. **Continuous improvement** — every workflow execution produces
   lessons that improve the next one

## Documentation

- [Vision and Philosophy](docs/1-vision.md) — why this approach,
  and what changes about how engineers work
- [Workflow Design](docs/2-workflow-design.md) — the three-loop
  workflow, config hierarchy, and guardrails
- [Harness Engineering](docs/3-harness-engineering.md) — research
  notes on the emerging discipline
- [Architecture Options](docs/4-architecture-options.md) — delivery
  mechanism evaluation and decision
- [References](docs/5-references.md) — source material and prior
  art
- [Plan — Stage 1](docs/6-plan-local-agent.md) — local agent skills
- Plan — Stage 2 — Backend harness (planned after Stage 1
  retrospective)

## Demo

An interactive walkthrough of the three-loop workflow
(Plan → Implement → Review):

```bash
open demo/loop1-plan-flow.html
```

No server required — it's a self-contained HTML file.

## Status

Design phase complete. Starting Stage 1: validating the workflow
using Skills before building the backend.
