---
name: reins-implement
description: >-
  Implement an approved plan from .reins/plans/. Reads the plan,
  validates it is ready, then writes code and tests per the
  plan's AC. Use when the user says "implement" or
  "reins-implement" and provides a story ID.
---

# reins-implement

Implement an approved plan. The plan is the spec — follow it.

## Invocation

The user provides a story ID:

`/reins-implement {story_id}`

Read the plan from `.reins/plans/{story_id}.md`. If the file
doesn't exist, stop and tell the user to run `/reins-plan`
first.

## Step 1: Validate the Plan

Before writing any code, check:

- **Plan exists** — `.reins/plans/{story_id}.md` is present
  and readable
- **No open questions** — if the plan has an Open Questions
  section with unresolved items, stop. Tell the user which
  questions need answers and suggest `/reins-refine` to
  update the plan.
- **Files are reachable** — spot-check that the files listed
  in the plan's `files:` frontmatter exist (for `modify`
  actions) or that the parent directory exists (for `create`
  actions). If a file was moved or deleted since planning,
  stop and report.
- **Scope is clear** — if the plan has a PR breakdown, confirm
  which PR the user wants implemented now. Do not implement
  multiple PRs in one pass.

If any check fails, stop and explain what's wrong. Do not
proceed with partial information.

## Step 2: Implement

Work through the plan's Per-Criterion Plan section, one AC
at a time:

1. Read the relevant source files for this AC
2. Implement the change described in the plan's Approach
3. Write tests alongside the code — not after
4. Move to the next AC

After all ACs are implemented, run the full test suite.

## Step 3: Report

Print a summary:

```
Implementation complete for {story_id}.
- {N} files modified, {M} files created
- Tests: {pass/fail summary}

When ready: /reins-raise-pr {story_id}
```

If tests fail, report which tests and why. Do not silently
skip failures.

## Constraints

- **Follow the plan** — implement what the plan says. If you
  discover the plan is wrong or incomplete mid-implementation
  (a file doesn't have the function the plan references, a
  dependency is missing, the approach won't work), stop and
  tell the user. Do not improvise a different approach.
- **Stay in scope** — only modify files listed in the plan's
  `files:` frontmatter. If you find you need to change an
  unplanned file, flag it to the user with a rationale
  before proceeding.
- **Tests alongside code** — every AC that changes behavior
  must have a corresponding test. Write the test in the same
  pass as the implementation, not as a separate step.
- **Run linting and tests before declaring done** — run the
  project's full verification suite (check AGENTS.md or
  Makefile for the command — e.g. `make verify`), not
  targeted file checks. Then run the full test suite. Report
  failures honestly; do not declare done if either fails.
- **No planning** — do not re-explore the codebase to
  second-guess the plan. The plan already did that work.
  Trust it, or reject it — don't silently deviate.
