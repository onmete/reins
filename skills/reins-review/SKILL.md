---
name: reins-review
description: >-
  Review an implementation against its plan's acceptance criteria
  and code quality. Reads the plan, checks the git diff, runs
  tests, and writes a review to .reins/reviews/. Use when the
  user says "review" or "reins-review" after implementing.
---

# reins-review

Review the implementation: adherence to the plan's acceptance
criteria AND code quality. Do NOT fix anything — report only.

## Invocation

`/reins-review {story_id}`

Read the plan from `.reins/plans/{story_id}.md`. If the plan
doesn't exist, stop.

## Step 1: Gather Evidence

1. **Read the plan** — extract the AC list and the planned
   file list from the YAML frontmatter
2. **Read the git diff** — `git diff` against the base branch.
   Read diffs per area (endpoints, models, utils, tests)
   rather than one massive diff.
3. **Read the changed files** — understand what was actually
   implemented

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
  (e.g., business logic in an endpoint, config parsing in
  a model)
- **Error handling** — are errors silently swallowed, or is
  an exception missing where failure is plausible?
- **Duplication** — is there copy-pasted logic that should
  be shared?
- **Naming** — only flag if genuinely misleading or
  inconsistent with established codebase patterns. Not
  stylistic preferences.
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
- Mark **unsure** findings as NEEDS_REVIEW or lower
  confidence

This step filters false positives. Do not skip it when there
are FAIL or issue candidates.

## Step 5: Check Scope Drift

Compare files actually modified (from `git diff`) against the
plan's `files:` frontmatter. Flag any drift:

- **Planned but untouched** — a file the plan said to modify
  but wasn't changed. Why?
- **Unplanned modification** — a file changed that wasn't in
  the plan. Is it a reasonable addition or scope creep?

Omit if no drift.

## Step 6: Write the Review

Save to `.reins/reviews/{story_id}.md` using the format below.

Then print a summary:

```
Review for {story_id}: {verdict}
Score: {overall_score}/100
- {N} AC passed, {M} failed, {K} need human review
- Code quality issues: {count or "none"}
- Scope drift: {yes/no}

You need to evaluate these findings — do not blindly
accept them as correct. When ready: /reins-retro {story_id}
```

## Review Format

```markdown
---
story_id: {ID}
overall_score: {0-100}
verdict: pass | fail | needs_review
criteria:
  - id: 1
    description: {AC text}
    status: PASS | FAIL | NEEDS_REVIEW
    evidence: {what you observed}
  - id: 2
    description: {AC text}
    status: FAIL
    evidence: {what's missing or wrong}
---

## Summary

{X}/{Y} acceptance criteria met. Brief overall assessment.

## Adherence Issues

Only include issues confirmed by verification (Step 4).

### Issue 1: {title}
- **AC:** which criterion this relates to
- **Expected:** what should have happened
- **Actual:** what actually happened
- **Severity:** low | medium | high
- **Confidence:** confirmed | unsure

Omit this section if all ACs pass.

## Code Quality Issues

Only flag concrete concerns confirmed by verification.
Do not manufacture issues for completeness.

### Issue 1: {title}
- **Category:** architecture | error handling | duplication |
  naming | tests
- **Location:** file:function
- **Concern:** what's wrong and why it matters
- **Severity:** must-fix | should-fix | nice-to-have
- **Confidence:** confirmed | unsure

Omit this section if nothing meaningful to flag.

## Scope Drift

| Planned | Actual | Match |
|---------|--------|-------|
| {file} ({action}) | {modified/created/untouched} | yes/drift |

Omit this section if no drift.
```

## Constraints

- **Report only** — do not fix, edit, or improve any code.
  If something is wrong, describe it. The user decides
  what to do next.
- **Be strict on adherence** — PASS means fully met.
  "It mostly works" is FAIL with a low severity note.
- **Be honest on quality** — only flag real concerns. If
  the code is clean, say so. A review with zero quality
  issues is a good review, not an incomplete one.
- **Evidence-based** — every score and every issue needs a
  reason. Point to the specific code, test, or behavior.
