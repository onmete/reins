# Reins

A deterministic backend that drives AI agent runtimes through a
multi-loop software development workflow. The backend holds the reins
(workflow, transitions, gates) while the agent provides the horsepower
(code generation, editing, testing).

## Status

Design phase complete. Stage 1 (skills) validated. Skills
available locally via `install.sh` (symlinks) and remotely
as an ACP session-config / workflow import.

## Project Structure

```
.claude/
  skills/
    reins-feature-spec/SKILL.md — Feature specification (+ ADRs)
    reins-decompose/SKILL.md    — Feature → Epics + Stories in Jira
    reins-spike/SKILL.md        — Time-boxed research → ADR
    reins-story-spec/SKILL.md   — Requirements spec from a story
    reins-plan/SKILL.md         — Implementation plan (+ optional ADR)
    reins-implement/SKILL.md    — Code + tests from approved plan
    reins-raise-pr/SKILL.md     — Create PR with structured description
    reins-review/SKILL.md       — Self-review against plan ACs
    reins-fix/SKILL.md          — Address review findings
    reins-deliver/SKILL.md      — Plan → PR (automatic)
    reins-work-on/SKILL.md      — Full workflow with plan checkpoint
    reins-retro/SKILL.md        — Feedback capture and skill improvement
  rules/
    reins-guardrails.md         — Workflow guardrails (always loaded)
  agents/
    code-reviewer.md            — Read-only verification subagent
.ambient/
  workflows/
    work-on-story.json          — ACP workflow: full story lifecycle
    deliver-story.json          — ACP workflow: deliver approved plan
    plan-story.json             — ACP workflow: plan a story
skills/                         — Symlink → .claude/skills/
docs/
  1-vision.md               — Philosophy and motivation
  2-workflow-design.md       — Three-loop workflow, config hierarchy
  3-harness-engineering.md   — Research notes on harness engineering
  4-architecture-options.md  — Delivery mechanism evaluation
  5-references.md            — Source material and prior art
  6-plan-local-agent.md      — Stage 1 plan (local agent skills)
CLAUDE.md                    — Session instructions (ACP + Claude Code)
.mcp.json                    — MCP server declarations (Jira)
install.sh                   — Symlink skills to local runtime
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
- Artifacts directory is `.reins/` (feature-specs, specs, plans,
  adrs, reviews)
