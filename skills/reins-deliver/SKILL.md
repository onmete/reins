---
name: reins-deliver
description: >-
  Deliver an approved plan: implement, raise PR, self-review,
  fix, and final review — all automatic. Use after the plan
  has been approved via /reins-plan. Starts with a clean
  context, no plan discussion history.
---

# reins-deliver

Pick up from an approved plan and deliver it: implement,
raise PR, self-review, fix if needed, final review.

Use this instead of `/reins-work-on` when plan refinement
was lengthy and you want a fresh context for implementation.

## Invocation

`/reins-deliver {story_id}`

Read the plan from `.reins/plans/{story_id}.md`. If the plan
doesn't exist, stop and tell the user to run `/reins-plan`
first.

## Phase 1: Implement

Follow the `/reins-implement` instructions:

1. Validate the plan (open questions, files reachable)
2. Implement each AC with tests
3. Run the project's verification suite and tests

## Phase 2: Raise PR

Follow the `/reins-raise-pr` instructions:

1. Check for `.github/` PR templates
2. Compose PR description from the plan
3. Create PR via `gh`, store URL in plan frontmatter

## Phase 3: Self-Review (Round 1)

Follow the `/reins-review` instructions:

1. Gather evidence (plan, diff, changed files)
2. Assess adherence and code quality
3. Verify findings with subagents
4. Post review comments on the PR
5. Write local review to `.reins/reviews/{story_id}.md`

If all ACs pass and no quality issues, skip to the end.

## Phase 4: Fix (if review found issues)

Follow the `/reins-fix` instructions:

1. Read findings from review and PR comments
2. Fix issues, write/update tests
3. Reply to PR comments
4. Push fixes

## Phase 5: Self-Review (Round 2 — Final)

Follow the `/reins-review` instructions for round 2:

1. Focus on what changed since the fix
2. Post only new findings
3. This is the final AI review

## Done

```
Delivery complete for {story_id}.
PR: {PR URL}
Review: {verdict}, score {overall_score}/100

PR is ready for human review.
For skill improvements: /reins-retro {story_id}

— reins
```

## Constraints

- **Plan must be approved** — if the plan has open questions
  or status is still "draft", stop and tell the user.
- **Everything is automatic** — no checkpoints. Implement,
  PR, review, fix, final review run without stopping.
- **Same rules as individual skills** — each phase follows
  the constraints of its corresponding skill.
- **Max 2 review rounds** — after round 2, remaining issues
  go to the human reviewer.
- **Signature** — all PR comments and descriptions end with
  `— reins`.
