---
name: reins-review
description: >-
  Review an implementation against its plan's acceptance criteria
  and code quality. Posts findings as PR comments via gh. Writes
  a local review to .reins/reviews/. Use after /reins-raise-pr.
---

# reins-review

Review the implementation: adherence to the plan's acceptance
criteria AND code quality. Post findings on the PR. Do NOT fix
anything — report only.

## Invocation

`/reins-review {story_id}`

Read the plan from `.reins/plans/{story_id}.md`. If the plan
doesn't exist, stop. Get the PR URL from the plan's `pr:`
frontmatter field (written by `/reins-raise-pr`).

## Step 1: Gather Evidence

1. **Read the plan** — extract the AC list and the planned
   file list from the YAML frontmatter
2. **Read the PR diff** — use `gh pr diff` or `git diff`
   against the base branch. Read diffs per area (endpoints,
   models, utils, tests) rather than one massive diff.
3. **Read the changed files** — understand what was actually
   implemented
4. **Check review round** — if `.reins/reviews/{story_id}.md`
   already exists, this is round 2. Read the previous review
   and focus on what changed since the fix.

Do not read the full codebase. The diff and the plan are your
scope. Do not re-run tests — the implement skill already
gated on that.

## Step 2: Assess Adherence

For each acceptance criterion in the plan, score it:

- **PASS** — the AC is fully met. Evidence is clear.
- **FAIL** — the AC is not met or only partially met.
  Describe what's missing.
- **NEEDS_REVIEW** — you can't determine pass/fail from the
  code alone (e.g., requires manual testing, the AC is
  ambiguous, or the behavior depends on runtime conditions).
  Explain why.

Be strict. PASS means fully met, not "mostly done" or
"close enough."

## Step 3: Assess Code Quality

Only raise issues if you have a concrete concern — not as a
checklist to fill. Skip any category that has nothing
meaningful to flag.

- **Architecture** — is logic clearly in the wrong layer?
- **Error handling** — are errors silently swallowed?
- **Duplication** — copy-pasted logic that should be shared?
- **Naming** — only if genuinely misleading or inconsistent
  with established codebase patterns.
- **Tests** — do tests cover behavior (specific assertions)
  or just confirm the code runs without error?

## Step 4: Verify Findings

Before finalizing any FAIL verdict or code quality issue,
verify each finding is real. For each candidate issue, launch
a subagent to:

- Read the specific file(s) and any related context (callers,
  tests, existing patterns)
- Return a verdict: **confirmed** / **not an issue** /
  **unsure**, with a one-sentence rationale

After all verifications complete:
- Drop any finding whose verdict is **not an issue**
- Keep **confirmed** findings at full confidence
- Mark **unsure** findings as NEEDS_REVIEW

Do not skip this step when there are FAIL or issue candidates.

## Step 5: Check Scope Drift

Compare files actually modified against the plan's `files:`
frontmatter. Flag planned-but-untouched files and unplanned
modifications. Omit if no drift.

## Step 6: Compute Score

Start at 100 and deduct:

- **−15** per FAIL AC
- **−5** per NEEDS_REVIEW AC
- **−10** per must-fix quality issue
- **−3** per should-fix quality issue
- **−5** for scope drift (any unplanned files modified)

Floor at 0. The score represents confidence that the PR is
ready to merge without further changes.

## Step 7: Post on PR and Write Local Review

### Post PR review via `gh`

Post a single PR review using `gh api` or `gh pr review`:

- **If all ACs pass and no quality issues:** approve the PR
  with a summary comment.
- **If any FAIL or quality issues:** request changes with a
  summary comment listing all findings.

For code quality issues with a specific location, post inline
comments on the relevant lines of the diff.

Every comment and the review summary must end with `— reins`.

### Round 2 behavior

If this is round 2 (previous review exists):
- Start the summary with "Round 2 review" so it's clear
- Only post NEW findings — do not re-post issues from round 1
  that were addressed
- Any remaining issues from round 1 that were NOT fixed:
  note them in the summary as "still open"
- After round 2, the workflow stops. Remaining issues are
  for the human reviewer.

### Write local review

Save to `.reins/reviews/{story_id}.md` using the format below.
On round 2, overwrite the previous review with the updated
state.

Then print:

```
Review for {story_id}: {verdict} (round {1|2})
Score: {overall_score}/100
- {N} AC passed, {M} failed, {K} need human review
- Code quality issues: {count or "none"}
- PR comments posted.

{If round 1 with issues:}
  When ready: /reins-fix {story_id}
{If round 1 all pass:}
  PR is ready for human review.
{If round 2:}
  PR is ready for human review.
```

## Review Format

```markdown
---
story_id: {ID}
review_round: 1 | 2
overall_score: {0-100}
verdict: pass | fail | needs_review
criteria:
  - id: 1
    description: {AC text}
    status: PASS | FAIL | NEEDS_REVIEW
    evidence: {what you observed}
---

## Summary

{X}/{Y} acceptance criteria met. Brief overall assessment.

## Adherence Issues

Only include issues confirmed by verification (Step 4).

### Issue 1: {title}
- **AC:** which criterion
- **Expected:** what should have happened
- **Actual:** what actually happened
- **Severity:** low | medium | high
- **Confidence:** confirmed | unsure

Omit if all ACs pass.

## Code Quality Issues

Only flag concrete concerns confirmed by verification.

### Issue 1: {title}
- **Category:** architecture | error handling | duplication |
  naming | tests
- **Location:** file:function
- **Concern:** what's wrong and why it matters
- **Severity:** must-fix | should-fix | nice-to-have
- **Confidence:** confirmed | unsure

Omit if nothing meaningful to flag.

## Scope Drift

| Planned | Actual | Match |
|---------|--------|-------|
| {file} ({action}) | {modified/created/untouched} | yes/drift |

Omit if no drift.
```

## Constraints

- **Report only** — do not fix, edit, or improve any code.
- **Be strict on adherence** — PASS means fully met.
- **Be honest on quality** — only flag real concerns. Zero
  quality issues is a good review, not an incomplete one.
- **Evidence-based** — every score and issue needs a reason.
- **PR comments are mandatory** — the local review file is
  not a substitute. Every finding must be posted on the PR
  via `gh` before writing the local file. If `gh` fails,
  report the failure to the user instead of silently
  continuing with only the local file.
- **Max 2 rounds** — round 2 is the final AI review.
  Anything remaining goes to the human reviewer.
- **Signature** — every PR comment ends with `— reins`.
