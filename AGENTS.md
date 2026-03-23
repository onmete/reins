# Reins

A deterministic backend that drives AI agent runtimes through a
multi-loop software development workflow. The backend holds the reins
(workflow, transitions, gates) while the agent provides the horsepower
(code generation, editing, testing).

## Status

Design phase complete. Starting Stage 1 (Cursor skills + rules)
to validate the workflow before building the backend.

## Project Structure

```
docs/
  1-vision.md               — Philosophy and motivation
  2-workflow-design.md       — Three-loop workflow, config hierarchy
  3-harness-engineering.md   — Research notes on harness engineering
  4-architecture-options.md  — Delivery mechanism evaluation
  5-references.md            — Source material and prior art
  6-plan-local-agent.md      — Stage 1 plan (local agent skills)
skills/
  reins-plan/SKILL.md        — Plan generation skill
  reins-retro/SKILL.md       — Feedback capture and skill improvement
install.sh                   — Install skills globally (~/.cursor/skills)
README.md                    — Project overview
```

## Key Concepts

- **Three loops:** Plan (team) → Implement + self-review (agent)
  → Review (human)
- **Backend drives, agent executes:** deterministic state machine
  invokes focused agent tasks per phase
- **Guardrails:** org-level policies that cannot be overridden
  (security, coverage, approved models)
- **Adherence assessment:** agent self-scores implementation
  against acceptance criteria before human review

## Guidelines

- Keep docs concise and opinionated
- Wrap prose at 78 characters for readability in terminals and
  diffs
- Prefer concrete examples over abstract descriptions
- CLI tool name is `reins`, Python package is `reins`
- Artifacts directory is `.reins/` (stories, runs)
