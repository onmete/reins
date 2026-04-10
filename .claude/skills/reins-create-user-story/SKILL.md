---
name: reins-create-user-story
description: >-
  Create a user story in Jira under the OpenShift Lightspeed
  Service project. Builds a well-structured story with summary,
  description, and acceptance criteria, then creates it via
  acli. Use when the user says "create story",
  "reins-create-user-story", "new story", or wants to add a
  user story to the backlog.
---

# reins-create-user-story

Create a user story in Jira. The story lands in the backlog
with no version allocation unless the user specifies one.

## Defaults

| Setting | Value |
|---------|-------|
| Project key | `OLS` (OpenShift Lightspeed Service) |
| Issue type | Story |
| Destination | Backlog (no transition needed) |
| Fix version | None (unless user specifies) |

## Invocation

`/reins-create-user-story {summary or description of work}`

The user provides what the story should cover — anything from
a one-liner to a detailed brief. The agent shapes it into a
proper story.

## CLI Tools

This skill uses **acli** (Atlassian CLI). If not
authenticated, run `acli auth login` first.

| Command | Purpose |
|---------|---------|
| `acli jira workitem create ...` | Create the story |
| `acli jira workitem search --jql "..." --json` | Check for duplicates or find parent epic |

## Step 1: Gather Context

Extract from the user's input:

- **Summary** — concise, descriptive title (max ~80 chars).
  This is the Jira issue title, not a user-story sentence.
- **User story** — "As a {persona}, I want {goal} so that
  {benefit}" format.
- **Description** — additional context, background, technical
  detail, links to relevant resources. Sits below the user
  story sentence.
- **Acceptance criteria** — specific, testable bullet points.
  If the user didn't provide AC, draft them and present for
  approval before creating the issue.
- **Parent epic** — if the user mentions an epic or parent
  issue, note the key (e.g. `OLS-1234`)
- **Labels** — if the user mentions any
- **Priority** — if mentioned; omit otherwise (Jira default)
- **Fix version** — only if explicitly requested

If the user's input is too vague to form AC, ask for
clarification. Do not invent requirements.

## Step 2: Present the Story for Approval

Show the story to the user before creating it:

```
Story to create in OLS:

Summary: {summary}

## User Story

As a {persona},
I want {goal}
so that {benefit}.

**Description**
{additional context, background, technical detail, links}

## Acceptance Criteria

* {AC 1}
* {AC 2}
* ...

Parent: {epic key, or "none"}
Labels: {labels, or "none"}
Fix Version: {version, or "none"}
```

Then ask:

```
Options:
  approve — create this story in Jira
  revise  — tell me what to change
  stop    — cancel
```

**Wait for the user.** Do NOT create the issue without
explicit approval.

## Step 3: Create the Story

Write the description to a temporary file (to avoid shell
escaping issues), then create the issue via `acli`:

```bash
cat > /tmp/jira-description.md << 'DESC'
{see Description Format below}
DESC

acli jira workitem create \
  --project OLS \
  --type Story \
  --summary "{approved summary}" \
  --description-file /tmp/jira-description.md \
  --json
```

Include optional flags only when provided:

- **parent** — `--parent {epic key}`
- **labels** — `--label "label1,label2"`
- **assignee** — `--assignee "user@example.com"`

### Description Format

The description field must follow this exact structure
(matching the project's existing story format):

```markdown
## User Story

As a {persona},
I want {goal}
so that {benefit}.

**Description**
{Additional context, background, technical detail.
Include links to relevant resources where applicable.}

## Acceptance Criteria

* {AC 1}
* {AC 2}
* {AC 3}
```

Key formatting rules:
- Use `## User Story` and `## Acceptance Criteria` as H2
  headers
- The persona/want/so-that block goes under User Story
- Additional context goes under a bold `**Description**`
  label within the User Story section
- AC items use `*` bullets (not checkboxes — Jira renders
  these as a plain list)

## Step 4: Report

After successful creation, report:

```
Created: {ISSUE-KEY} — {summary}
URL: {issue URL}
Status: Backlog

Next steps:
  - /reins-plan {ISSUE-KEY}
  - /reins-work-on {ISSUE-KEY}
```

If creation fails, report the error and suggest remediation.

## Constraints

- **Human gate is mandatory** — never create a Jira issue
  without explicit user approval.
- **No version allocation by default** — only set fixVersions
  when the user explicitly requests it.
- **Stay grounded** — acceptance criteria describe observable
  behavior, not implementation details.
- **No duplicates** — if the summary closely matches an
  existing story, warn the user. Use
  `acli jira workitem search --jql '...' --json` with a
  query like
  `project = "OLS" AND type = Story AND summary ~ "{terms}"`
  to check when in doubt.
- **Use acli** — all Jira operations go through the `acli`
  CLI. If a command fails with an auth error, prompt the
  user to run `acli auth login`. Use `--json` for
  machine-readable output.
