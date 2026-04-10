---
name: reins-fix
description: >-
  Address review comments on a PR. Reads the review from
  .reins/reviews/ and PR comments, fixes the issues, and
  replies to resolved comments. Use after /reins-review
  posts findings.
---

# reins-fix

Address findings from a reins-review. Fix the issues, reply
to PR comments, and push the changes.

## Invocation

`/reins-fix {story_id}`

## Step 1: Read the Findings

1. **Read the plan** from `.reins/plans/{story_id}.md` — get
   the PR URL from the `pr:` frontmatter field and the file
   list for scope reference
2. **Read the local review** from `.reins/reviews/{story_id}.md`
   — this has the structured list of adherence and quality
   issues
3. **Read PR comments** via `gh` using the PR URL — get the
   actual comments posted on the PR, including any additional
   comments from human reviewers

Separate the issues into:
- **Adherence failures** — AC not met, must fix
- **Code quality (must-fix)** — real problems to address
- **Code quality (should-fix / nice-to-have)** — address if
  straightforward, skip if complex and note why
- **Human reviewer comments** — treat the same as quality
  issues; address what's clear, ask if ambiguous

## Step 2: Fix

Work through the issues one at a time:

1. Read the relevant source files
2. Make the targeted fix
3. Write or update tests if the fix changes behavior
4. Move to the next issue

Stay in scope. Fix what was flagged — do not refactor
adjacent code, add unrelated improvements, or expand the
change.

## Step 3: Respond to PR Comments

For each review comment that was addressed:

- Reply to the comment with a brief note of what was done
  (e.g., "Fixed — moved validation to the service layer")
For comments that were NOT addressed (e.g., too complex,
out of scope, disagree):

- Reply explaining why (e.g., "Deferred — this would
  require refactoring the auth module, out of scope for
  this story")

Do not leave comments without a response.

## Step 4: Push and Report

Run linting, type checks, and tests. If they pass, commit
and push the fixes.

Then print:

```
Fixes pushed for {story_id}.
- {N} issues addressed, {M} deferred
- Tests: passing

When ready: /reins-review {story_id}
```

This triggers the round 2 review, which is the final AI
review before human review.

## Constraints

- **Targeted fixes only** — fix what was flagged. Do not
  improve code that wasn't mentioned in the review.
- **Stay in scope** — respect the plan's file list. If a
  fix requires touching an unplanned file, flag it to the
  user first.
- **Respond to every comment** — addressed or not, every PR
  comment gets a reply explaining the outcome.
- **Run tests** — do not push if linting or tests fail.
