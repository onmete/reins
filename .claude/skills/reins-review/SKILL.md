---
name: reins-review
description: >-
  Review a pull request for code quality and requirement
  adherence. Works standalone on any PR. When a reins plan
  or Jira ticket is attached, also checks requirement
  adherence. Posts findings as PR comments via gh. Writes a
  local review to .reins/reviews/.
---

# reins-review

Review a pull request: code quality and — when requirements
are available — adherence. Post findings on the PR. Do NOT
fix anything — report only.

## Invocation

`/reins-review {story_id}` — find PR from plan frontmatter
`/reins-review {PR_URL or #PR_NUMBER}` — review any PR
`/reins-review` — review the PR on the current branch

## Step 1: Identify the PR and Requirements

### Determine the PR

Try these in order until one works:

1. **Story ID given** — read `.reins/plans/{story_id}.md`,
   get the PR URL from the `pr:` frontmatter field
2. **PR URL or number given** — use directly
3. **Current branch** — run `gh pr view --json url` to find
   an open PR for the current branch
4. **Nothing found** — stop and ask the user

Fetch the PR title and description via
`gh pr view --json title,body`.

### Determine requirements source

Check in priority order. Use the first source found:

1. **Plan** — `.reins/plans/{story_id}.md` exists → use its
   acceptance criteria
2. **Jira** — PR title or description contains a Jira-style
   ID (pattern: `[A-Z][A-Z0-9]+-\d+`, e.g. `OLS-2673`).
   Fetch the issue via
   `acli jira workitem view {KEY} --json`.
   Extract acceptance criteria from the issue description —
   look for bullet lists, checkboxes, or a section headed
   "Acceptance Criteria", "AC", or "Definition of Done".
3. **None** — no requirements found; skip adherence, do
   code quality review only

Record which mode is active: `plan`, `jira`, or `quality-only`.

## Step 2: Gather Evidence

1. **Read requirements** — the plan's AC list, or the Jira
   issue's extracted ACs (depending on mode)
2. **Read the PR diff** — use `gh pr diff` or `git diff`
   against the base branch. Read diffs per area (endpoints,
   models, utils, tests) rather than one massive diff.
3. **Read the changed files** — understand what was actually
   implemented
4. **Check review round** — if `.reins/reviews/{story_id}.md`
   already exists (plan mode only), this is round 2. Read
   the previous review and focus on what changed.

Scope is the diff and the requirements. Do not read the full
codebase. Do not re-run tests.

## Step 3: Assess Adherence

Skip this step in `quality-only` mode.

For each acceptance criterion, score it:

- **PASS** — fully met. Evidence is clear in the diff.
- **FAIL** — not met or only partially met. Describe what's
  missing.
- **NEEDS_REVIEW** — can't determine from code alone (e.g.,
  requires manual testing, the AC is ambiguous, or behavior
  depends on runtime conditions). Explain why.

Be strict. PASS means fully met, not "mostly done."

In `jira` mode, if the issue description has no clear ACs,
note this in the review summary and proceed with code
quality only.

## Step 4: Assess Code Quality

Only raise issues where you have a concrete concern — not
as a checklist to fill. Skip any category with nothing
meaningful to flag.

### Architecture

Is logic clearly in the wrong layer? (e.g., business logic
leaking into an endpoint handler, data access in a
controller)

### Error handling

- Are errors silently swallowed, or is an exception missing
  where failure is plausible?
- **Pattern consistency:** if a function has N-1 error paths
  that degrade gracefully (return None, log warning,
  fallback), verify the Nth path does too. A single
  unguarded call among guarded ones is the most common miss.
- **Cross-boundary exceptions:** for every new method call
  added in the diff, check what the **caller** does if that
  method throws. Read the callee's exception paths, then
  verify the caller handles them. Don't treat methods as
  self-contained.

### Duplication

Copy-pasted logic that should be shared. Compare new code
against existing patterns in the changed files' neighbours.

### Naming

Only flag if genuinely misleading or inconsistent with
established codebase patterns. Do not flag stylistic
preferences.

### Tests

- Do tests cover behavior (specific assertions) or just
  confirm the code runs without error?
- Are edge cases from the requirements (plan or Jira)
  covered?
- Are there tests that will break due to implicit behavior
  changes not caught by the implementer?

### Other

- Dead code or obviously missing doc updates
- Security implications not addressed (token logging, size
  limits, injection)
- Bundled unrelated changes that should be in a separate PR

## Step 5: Verify Findings

Before finalizing any FAIL verdict or code quality issue,
verify each finding is real. For each candidate issue,
launch a read-only subagent (`code-reviewer`) to:

- Read the specific file(s) and related context (callers,
  tests, existing patterns)
- Return a verdict: **confirmed** / **not an issue** /
  **unsure**, with a one-sentence rationale

After all verifications complete:

- Drop any finding whose verdict is **not an issue**
- Keep **confirmed** findings at full confidence
- Mark **unsure** findings as NEEDS_REVIEW (adherence) or
  lower confidence (quality)

Do not skip this step when there are FAIL or issue
candidates.

## Step 6: Check Scope Drift

Only in `plan` mode. Compare files actually modified against
the plan's `files:` frontmatter. Flag planned-but-untouched
files and unplanned modifications. Omit if no drift.

## Step 7: Compute Score

Start at 100 and deduct:

- **−15** per FAIL AC
- **−5** per NEEDS_REVIEW AC
- **−10** per must-fix quality issue
- **−3** per should-fix quality issue
- **−5** for scope drift (any unplanned files modified)

In `quality-only` mode, start at 100 and deduct only for
quality issues (no adherence deductions). In `jira` mode
without clear ACs, same as quality-only.

Floor at 0.

## Step 8: Write Local Review

Save to `.reins/reviews/{review_id}.md` where `review_id`
is `{story_id}` (plan/jira mode) or `pr-{PR_NUMBER}`
(standalone). On round 2, overwrite the previous review.

Then print the review summary to the user:

```
Review for {id}: {verdict} ({mode} mode, round {1|2})
Score: {overall_score}/100
- {N} AC passed, {M} failed, {K} need human review
  (or: "No requirements found — code quality review only")
- Code quality issues: {count or "none"}

Options:
  post     — post findings as PR comments
  fix      — skip posting, go straight to fixing
  stop     — review saved locally, done for now
```

Stop here and wait for the user's response. Do NOT post
PR comments unless the user says "post" (or the skill is
invoked from `/reins-deliver` or `/reins-work-on`, which
pass `--post` implicitly).

## Step 9: Post on PR (gated)

Only execute this step when the user approves posting, or
when invoked as part of `/reins-deliver` or `/reins-work-on`
(which run without checkpoints after plan approval).

### Post PR review via `gh`

Post a single PR review using `gh api` or `gh pr review`:

- **All clear:** approve with a summary comment
- **Issues found:** request changes with a summary listing
  all findings

For code quality issues with a specific location, post
inline comments on the relevant lines of the diff.


### Round 2 behavior (plan mode only)

If this is round 2 (previous review exists):

- Start the summary with "Round 2 review"
- Only post NEW findings — do not re-post addressed issues
- Note remaining issues from round 1 as "still open"
- After round 2, the workflow stops; remaining issues are
  for the human reviewer

After posting, print:

```
PR comments posted.

{If round 1 with issues:}
  When ready: /reins-fix {story_id}
{If all pass:}
  PR is ready for human review.
{If round 2:}
  PR is ready for human review.
```

## Review Format

```markdown
---
review_id: {story_id or pr-NUMBER}
mode: plan | jira | quality-only
review_round: 1 | 2
overall_score: {0-100}
verdict: pass | fail | needs_review
jira_issue: {PROJ-123 or omit}
criteria:
  - id: 1
    description: {AC text}
    source: plan | jira
    status: PASS | FAIL | NEEDS_REVIEW
    evidence: {what you observed}
---

## Summary

{X}/{Y} acceptance criteria met (or "Code quality review —
no requirements assessed"). Brief overall assessment.

## Adherence Issues

Only include issues confirmed by verification (Step 5).

### Issue 1: {title}
- **AC:** which criterion
- **Source:** plan | jira
- **Expected:** what should have happened
- **Actual:** what actually happened
- **Severity:** low | medium | high
- **Confidence:** confirmed | unsure

Omit section if all ACs pass or quality-only mode.

## Code Quality Issues

Only flag concrete concerns confirmed by verification.

### Issue 1: {title}
- **Category:** architecture | error handling | duplication |
  naming | tests | other
- **Location:** file:function
- **Concern:** what's wrong and why it matters
- **Severity:** must-fix | should-fix | nice-to-have
- **Confidence:** confirmed | unsure

Omit if nothing meaningful to flag.

## Scope Drift

| Planned | Actual | Match |
|---------|--------|-------|
| {file} ({action}) | {modified/created/untouched} | yes/drift |

Omit if no drift or not in plan mode.
```

## Constraints

- **Report only** — do not fix, edit, or improve any code.
- **Be strict on adherence** — PASS means fully met.
- **Be honest on quality** — only flag real concerns. Zero
  quality issues is a good review, not an incomplete one.
- **Evidence-based** — every score and issue needs a reason.
- **Local review first** — always write the local review
  and present findings before posting to the PR. PR posting
  requires user approval (Step 9) unless running inside
  `/reins-deliver` or `/reins-work-on`. If `gh` fails when
  posting, report the failure to the user.
- **Max 2 rounds** — round 2 is the final AI review.
  Anything remaining goes to the human reviewer. Round 2
  only applies in plan mode (reins workflow).
- **Use acli** — fetch Jira issues via
  `acli jira workitem view {KEY} --json`. If a command
  fails with an auth error, prompt the user to run
  `acli auth login`.
