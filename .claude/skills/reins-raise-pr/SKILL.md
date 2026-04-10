---
name: reins-raise-pr
description: >-
  Create a pull request for an implemented story. Reads the plan
  to compose the PR description with summary, scope, and ACs.
  Use after /reins-implement completes successfully.
---

# reins-raise-pr

Create a pull request for an implemented story.

## Invocation

`/reins-raise-pr {story_id}`

## Step 1: Validate

- Verify `.reins/plans/{story_id}.md` exists
- Verify there are committed changes on the current branch
  that aren't on the base branch
- If the branch hasn't been pushed, push it

## Step 2: Compose PR Description

Also check `.github/CONTRIBUTING.md` for any PR guidelines
(title format, label requirements, etc.) and follow them.

### When a repo template exists

Check for `.github/PULL_REQUEST_TEMPLATE.md` (or templates
in `.github/PULL_REQUEST_TEMPLATE/`). If found, use it
**verbatim** as the skeleton — keep every section heading,
checkbox, and placeholder. Fill in the plan's content within
the template's sections. Do NOT add, remove, or rename
sections. Map the plan content to the closest template
section (approach → Description, ACs → Description or
Testing, etc.).

### When no repo template exists

Use this default format:

```markdown
## {summary from plan}

**Story:** {story_id}
**Scope:** {scope from plan}
**Risk:** {risk from plan}

### Approach

{approach section from the plan}

### Acceptance Criteria

{AC list from the plan, as checkboxes}

### Files Changed

{files list from plan frontmatter}

```

If the plan has a PR breakdown and this is one of multiple
PRs, note which PR this is and what it covers.

## Step 3: Create the PR

### Detect the target repository

PRs must target the canonical (upstream) repository, not
the user's fork:

1. Run `git remote -v` and look for a remote named
   `upstream`. If found, pass `--repo {upstream_owner/repo}`
   to `gh pr create`.
2. If no `upstream` remote exists, fall back to `origin`.

Never pass `--repo` pointing at the user's fork when an
`upstream` remote is configured.

### Create

Use `gh pr create` with the composed title and description.
If the plan's `story_id` looks like a Jira ID (e.g. `OLS-2673`),
use `{story_id}: {summary}` as the PR title. Otherwise use the
plan's summary alone.

After creation, update the plan's YAML frontmatter with the
PR URL:

```yaml
pr: https://github.com/org/repo/pull/123
```

This lets follow-up skills (`reins-review`, `reins-fix`)
find the PR without the user having to pass it.

Then print:

```
PR created: {PR URL}

When ready: /reins-review {story_id}
```

## Constraints

- **One PR per invocation** — if the plan has a PR breakdown,
  create only the PR the user asked for.
- **Do not modify code** — this skill only creates the PR.
  All code changes should already be committed.
