---
name: reins-retro
description: >-
  Improve reins skills or AGENTS.md based on user feedback.
  Use when the user identifies a pattern that should change
  how a skill works going forward — not just for this story,
  but for all future runs. Examples: "plans should always
  check for existing utils", "the plan format needs a
  dependencies section", "stop suggesting new files when
  existing ones can be extended". Do NOT trigger for
  one-off plan feedback that only applies to the current
  story — that is /reins-refine territory.
---

# reins-retro

Capture feedback from a workflow run and turn it into a
concrete improvement to a skill or AGENTS.md.

## Invocation

The user describes what went wrong (or could be better) after
running a skill. Examples:

- "The plan was too vague about testing"
- "reins-plan didn't check the existing validators"
- "The plan scope was always 'medium' — it should consider
  file count"
- "Add a rule: always check for existing utility functions
  before proposing new ones"

## Workflow

1. **Understand the feedback** — ask clarifying questions if
   the problem is ambiguous. What happened? What should have
   happened?
2. **Identify the target** — decide where the fix belongs:
   - A specific skill (e.g., `reins-plan/SKILL.md`) — if the
     issue is about that skill's behavior or output
   - `AGENTS.md` — if the issue is a project-wide convention
     that all skills (and general coding) should follow
3. **Read the target file** — understand the current
   instructions before proposing changes
4. **Draft the edit** — write the specific change:
   - Add a new constraint to an existing section
   - Tighten an existing instruction
   - Add a workflow step
   - Restructure if the skill has grown unclear
5. **Show the proposed diff** — print the before/after so the
   user can review. Do NOT apply yet.
6. **Apply on approval** — only edit the file after the user
   confirms

## What Counts as a Good Edit

- **Specific** — "Check for existing utility modules in
  `src/utils/` before proposing new files" not "Be more
  thorough"
- **Actionable** — the agent can follow it mechanically
- **Minimal** — change the least amount needed. Don't
  reorganize sections unless the skill is genuinely unclear.
- **Tightens, not bloats** — if adding a constraint, check
  if an existing one covers the same ground and can be
  refined instead of adding another bullet

## Constraints

- **Show before applying** — never edit a skill without
  showing the user the proposed change first
- **One concern per retro** — if the user has multiple
  issues, address them one at a time so each edit can be
  evaluated independently
- **Stay under 500 lines** — if the target skill is
  approaching 500 lines, consolidate or generalize instead
  of appending. The 500-line limit is a hard constraint from
  the SKILL.md standard.
- **Preserve voice** — match the writing style of the
  existing skill. Don't introduce a different tone or
  structure convention.
- **Git is the log** — do not maintain a changelog or
  "lessons learned" section within the skill. The git
  history records what changed and why (via commit messages).

## Deciding: Skill vs AGENTS.md

| Signal | Target |
|--------|--------|
| Only affects one skill's output | Skill |
| Affects how all code is written | AGENTS.md |
| About plan format or structure | `reins-plan` |
| About coding style or conventions | AGENTS.md |
| About exploration depth or strategy | Skill |
| About project architecture patterns | AGENTS.md |

When unsure, default to the skill. It's easier to promote a
skill-specific rule to AGENTS.md later than to remove a
project-wide rule that only one skill needed.
