# Workflow Design

## Overview

The system is a multi-loop workflow that automates the path from Jira story to
merged PR, with human judgment injected at design-level decisions rather than
implementation-level details.

It is **not** a separate agent backend. It is a configuration and workflow
layer that sits on top of existing AI coding CLIs (Claude Code, Cursor,
OpenCode), giving the team structural control over how agents behave.

## Why the Plan Lives in a Thread, Not a Ticket

A common instinct is to embed AI execution plans in Jira stories — "steps
for the AI to generate the code" agreed upon at refinement. This feels
disciplined but is the wrong location:

- **Plans go stale.** The moment AI starts implementing, it encounters
  things the plan didn't anticipate. A static plan in a Jira ticket can't
  adapt.
- **It's the old workflow with an AI step bolted on.** Asking humans to
  write prompts in a project management tool is "doing the same things
  faster," not "doing things differently."
- **Code quality belongs in-repo.** `AGENTS.md`, coding standards, and
  convention files control how the agent writes code. The ticket should
  describe *what* and *why*, not *how to prompt the AI*.

The plan is a **conversation, not an artifact.** It evolves through team
discussion in a Slack thread, not frozen in a Jira ticket. Jira stays
focused on the problem (what/why). The thread is where the solution (how)
gets worked out interactively.

## The Three Loops

### Loop 1: Plan (Team)

**Trigger:** Jira story moves to "Ready for Dev"

1. AI reads the story (description, acceptance criteria, linked specs)
2. AI proposes an implementation plan:
   - Which files need to be created or modified
   - How each acceptance criterion maps to specific code changes
   - Estimated scope and risk assessment
3. Plan is posted to a Slack thread (or equivalent) for team discussion
4. Team discusses, scopes, adjusts the plan
5. Plan is approved (explicit approval mechanism — emoji react, command, etc.)

**Why this matters:** Reviewers don't need to second-guess the entire design
during PR review. The approach is agreed *before* any code is generated.

### Loop 2: Implement + Self-Review (Agent)

**Trigger:** Plan approved in Loop 1

1. AI implements the code changes following the agreed plan
2. AI writes tests alongside implementation (not after)
3. AI runs the test suite — fixes failures before proceeding
4. AI produces an **adherence assessment:**
   - Intent adherence score (0-100): does the implementation match the story?
   - Per-criterion checklist: each acceptance criterion marked PASS/FAIL with
     code references
5. If any criterion fails or score < 80, the agent loops back and fixes
6. AI creates a PR with the adherence assessment as the description

**Why this matters:** The agent validates its own work against the spec before
any human sees it. Most implementation issues are caught here.

### Loop 3: Review (Human)

**Trigger:** PR created with passing adherence assessment

1. Human reviews the PR — focused on:
   - Does the plan make sense for the broader system?
   - Are there architectural concerns the agent missed?
   - Security, performance, or maintainability issues?
2. Human provides feedback
3. Agent addresses feedback, re-runs adherence assessment
4. PR is merged

**Why this matters:** Human review is focused on judgment calls that require
system-level understanding, not line-by-line code inspection.

## Configuration Hierarchy

Inspired by Ansible's ARC (Agent Runtime Configuration) model:

| Level | Scope | What it controls |
|-------|-------|-----------------|
| **Org** | Organization-wide | Security policies, approved models, coverage thresholds, locked guardrails |
| **Team** | Business unit / team | Team conventions, architecture decisions, domain-specific standards |
| **Repo** | Individual repository | Repo-specific patterns, test guidance, module boundaries |
| **User** | Developer preferences | Personal overrides (within guardrail constraints) |

Lower levels inherit from higher levels. Org-level guardrails cannot be
overridden — this is how ProdSec and Legal constraints are enforced
structurally.

## Guardrails (Non-Negotiable)

Enforced at the org level, cannot be overridden:

- **Context exclusions:** `.env`, secrets, PEM/key files never included in AI
  context
- **Approved models:** only sanctioned models can be used
- **Locked instruction files:** security policy and coding standards cannot be
  modified by lower levels
- **Coverage thresholds:** minimum test coverage enforced
- **Mandatory integrations:** e.g., Jira MCP server cannot be removed

## Workflow Chain

The system supports the full SDLC, not just story implementation:

```
Feature Ideation → System Design Plan → Tech Proposal → Epic Creation → Epic Breakdown
                                                                              ↓
                                                                    Story Implementation → Test
                                                                    Spike Research
                                                                              ↓
                                                                    Triage → Bugfix → Test
```

Each workflow has entry gates (prerequisites), a process loop (the work), exit
gates (verification), and session recording (audit + learning).

## Integration Points

| System | Role | Mechanism |
|--------|------|-----------|
| **Jira** | Story source, status tracking | MCP server |
| **GitHub** | Code hosting, PRs | MCP server + git CLI |
| **Slack** | Team plan discussion (Loop 1) | Webhook / bot integration |
| **AI CLI** | Agent runtime | Claude Code / Cursor / OpenCode |
| **CI/CD** | Automated verification | Pipeline guardrails |

## Key Metrics

Borrowed from the "Structure Dictates Behavior" framework (ambient-code.ai):

| Metric | Measures | Goal |
|--------|----------|------|
| **Interrupt Rate** | Agent pauses requiring human input per task | ↓ |
| **Autonomous Completion Rate** | Tasks completed with zero interrupts | ↑ |
| **Mean Time to Correct** | Time from interrupt to resolution | ↓ |
| **Context Coverage Score** | % of interrupt categories with structural fix | ↑ |
| **Feedback-to-Demo Cycle Time** | Time from feedback to working demo | ↓ |
| **Adherence Score** | Average intent adherence across stories | ↑ |

Each interrupt is treated as a structural gap to fix (missing context,
undocumented convention, incomplete risk model) — not just a question to
answer. The goal is to systematically eliminate categories of interrupts.

## What This Is Not

- **Not a custom agent framework.** It uses existing AI CLIs as the runtime.
- **Not a replacement for Jira/GitHub/Slack.** It integrates with them.
- **Not fully autonomous.** Humans are in the loop at design decisions and
  final review. The goal is to make human involvement intentional and
  high-value, not to remove it.
