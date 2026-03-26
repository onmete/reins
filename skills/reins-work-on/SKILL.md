---
name: reins-work-on
description: >-
  End-to-end workflow for a story: plan, implement, raise PR,
  self-review, fix, and final review — with a developer
  checkpoint after planning. Use when the user says "work on"
  or wants to run the full reins workflow for a story.
---

# reins-work-on

Run the full reins workflow for a story in a single
conversation. The developer approves the plan, then
everything else runs automatically.

If plan refinement is lengthy, use `/reins-plan` and
`/reins-deliver` instead — they split planning from
delivery so each gets a clean context.

## Invocation

`/reins-work-on {story_id or story content}`

Accepts the same story input as `/reins-plan` — pasted
content, file reference, or Jira ID.

## Phase 1: Spec

Follow the `/reins-spec` instructions:

1. Assess readiness (AC present? bounded scope? right type?)
2. Explore context in the codebase
3. Clarify each AC (edge cases, implicit requirements,
   ambiguity, dependencies, conflicts)
4. Write the spec to `.reins/specs/{story_id}.md`
5. Print the spec

If the spec's readiness is "needs-clarification", present the
open questions and wait for answers. Update the spec and
re-assess until readiness is "ready".

For clear, well-scoped stories this phase is fast — the spec
confirms requirements are complete and moves on.

## Phase 2: Plan

Follow the `/reins-plan` instructions:

1. Check for spec (reads `.reins/specs/{story_id}.md` if it
   exists)
2. Evaluate the story
3. Explore the codebase
4. Write the plan to `.reins/plans/{story_id}.md`
5. Write ADR to `.reins/adrs/` if an architectural decision
   was made
6. Print the plan

### Checkpoint: Plan Approval

```
Plan written to .reins/plans/{story_id}.md

Options:
  approve  — proceed to implementation
  revise   — tell me what to change (stays in this phase)
  stop     — end here, continue later with /reins-implement
```

Wait for the developer. If "revise", incorporate the feedback
and re-print the plan. Loop until approved or stopped.

Do NOT proceed past this point without explicit approval.

## Phase 3: Implement

Follow the `/reins-implement` instructions:

1. Validate the plan (open questions, files reachable)
2. Implement each AC with tests
3. Run linting, type checks, and tests

## Phase 4: Raise PR

Follow the `/reins-raise-pr` instructions:

1. Check for `.github/` PR templates
2. Compose PR description from the plan
3. Create PR via `gh`, store URL in plan frontmatter

## Phase 5: Self-Review (Round 1)

Follow the `/reins-review` instructions:

1. Gather evidence (plan, diff, changed files)
2. Assess adherence and code quality
3. Verify findings with subagents
4. Post review comments on the PR
5. Write local review to `.reins/reviews/{story_id}.md`

If all ACs pass and no quality issues, skip to the end.

## Phase 6: Fix (if review found issues)

Follow the `/reins-fix` instructions:

1. Read findings from review and PR comments
2. Fix issues, write/update tests
3. Reply to PR comments
4. Push fixes

## Phase 7: Self-Review (Round 2 — Final)

Follow the `/reins-review` instructions for round 2:

1. Focus on what changed since the fix
2. Post only new findings
3. This is the final AI review

## Done

```
Workflow complete for {story_id}.
PR: {PR URL}
Review: {verdict}, score {overall_score}/100

PR is ready for human review.
For skill improvements: /reins-retro {story_id}

— reins
```

## Constraints

- **Plan checkpoint is mandatory** — never proceed past
  planning without explicit developer approval.
- **Everything after approval is automatic** — implement,
  PR, review, fix, final review run without stopping.
- **Same rules as individual skills** — each phase follows
  the constraints of its corresponding skill.
- **Stop is always an option** — the developer can interrupt
  at any point and resume later using the individual skill
  for the next phase.
- **Max 2 review rounds** — after round 2, remaining issues
  go to the human reviewer.
- **Signature** — all PR comments and descriptions end with
  `— reins`.
