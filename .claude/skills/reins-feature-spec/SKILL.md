---
name: reins-feature-spec
description: >-
  Produce a structured specification from a Jira Feature. Reads
  the feature, clarifies scope and constraints with the user,
  explores the codebase for architectural context, and writes a
  feature spec to .reins/feature-specs/. Produces ADRs when
  architectural decisions surface. Use when the user says
  "feature spec", "reins-feature-spec", or wants to specify a
  feature before decomposing it into epics and stories.
---

# reins-feature-spec

Produce a structured specification from a Jira Feature or
Initiative. Do NOT decompose into epics/stories — that's what
`/reins-decompose` does. This skill is about defining what the
feature is, not how to break it down.

## Invocation

The user provides a feature in one of these forms:

1. **Jira key** — `/reins-feature-spec PROJ-100` (uses
   `jira-mcp` to fetch the feature)
2. **Pasted content** — feature description directly in the
   conversation

If using Jira MCP and the `cloudId` is unknown, call
`getAccessibleAtlassianResources` to discover it, or ask the
user.

Extract the **feature ID**, **summary**, **description**, and
any **acceptance criteria** or **linked issues** from whatever
the user provides.

## Step 1: Read Feature Context

Gather context from multiple sources:

- **From Jira** — fetch the feature via `getJiraIssue` with
  `responseContentFormat: "markdown"`. Extract description,
  acceptance criteria, priority, linked issues (epics, stories,
  spikes already under this feature).
- **From Jira search** — use `searchJiraIssuesUsingJql` to
  find related features, epics, or stories in the same project
  that may overlap or conflict.
- **From the codebase** — read `AGENTS.md`, architecture docs,
  and relevant source files to understand the technical
  landscape the feature will touch.

## Step 2: Assess Readiness

Evaluate whether the feature is ready to spec:

- **Is there a clear goal?** A feature with no description or
  only a title cannot produce a useful spec. Ask the user to
  elaborate before proceeding.
- **Is the scope bounded?** Can you describe what "done" looks
  like at a high level? If the feature is open-ended ("improve
  the data pipeline"), flag it.
- **Are there success criteria?** Measurable outcomes that
  define whether the feature achieved its purpose.

If the feature is completely unready, stop and tell the user
what's missing.

## Step 3: Clarify with User

Interview the user to fill gaps. For each area, ask only what
is unclear — skip what the feature description already covers:

- **Scope boundaries** — what is explicitly in and out?
- **Success criteria** — how will we measure this worked?
- **Constraints** — performance budgets, backwards
  compatibility, security requirements, approved technologies?
- **Dependencies** — external services, other teams, features
  that must land first?
- **Migration/rollback** — does this change data schemas,
  APIs, or configurations that need migration paths?
- **Non-goals** — what might people assume is included but
  explicitly is not?
- **Users/personas** — who is affected and how?

For well-defined features this step is fast. For vague ones,
this is where the value is.

## Step 4: Write Feature Spec

Write the spec to `.reins/feature-specs/{feature_id}.md` using
the format below.

If `.reins/feature-specs/{feature_id}.md` already exists, ask
the user whether to overwrite or update.

## Step 5: Write ADRs (if applicable)

When architectural decisions surface during clarification —
choosing between meaningful alternatives with different
trade-offs — write ADRs to `.reins/adrs/{feature_id}-{slug}.md`.

Use the same ADR format as `/reins-plan`:

```markdown
# {Decision Title}

Date: {YYYY-MM-DD}
Feature: {feature_id}
Status: proposed

## Context

What is the situation that requires a decision? What forces
are at play? 2-4 sentences.

## Decision

What is the change we are proposing or have agreed to?

## Alternatives Considered

### {Alternative A}
- **Pros:** ...
- **Cons:** ...

### {Alternative B}
- **Pros:** ...
- **Cons:** ...

## Consequences

What becomes easier or harder as a result of this decision?
```

Only create ADRs when there were genuine alternatives with
lasting consequences. Do not create ADRs for obvious choices.

## Step 6: Update Jira

Add a comment to the Jira feature via `addCommentToJiraIssue`
summarizing the spec:

- One-line summary of the feature spec
- Link or reference to the local spec file
- List of ADRs produced (if any)
- Open questions (if any)

## Step 7: Report

Print the spec and tell the user:

```
Feature spec written to .reins/feature-specs/{feature_id}.md
{if ADRs: ADR(s) written to .reins/adrs/{feature_id}-*.md}

Readiness: ready | needs-clarification
{if needs-clarification: list the open questions}

When ready: /reins-decompose {feature_id}
```

## Feature Spec Format

```markdown
---
feature_id: {ID}
summary: {one-line summary}
readiness: ready | needs-clarification
date: {YYYY-MM-DD}
---

## Problem Statement

What problem are we solving and for whom? Why now? 2-4
sentences grounded in user/business need.

## Value Hypothesis

We believe that {feature} will {outcome} for {users},
measured by {success criteria}.

## Success Criteria

- {Criterion 1: measurable outcome}
- {Criterion 2: measurable outcome}

## Scope

### In Scope
- {Item 1}
- {Item 2}

### Out of Scope
- {Item 1 — why it's excluded}

## Technical Context

What exists today that this feature changes or extends.
Reference actual systems, services, modules, interfaces.
Identify architectural patterns the feature must respect.

## Constraints

- {Constraint 1 — e.g. backwards compatibility, performance
  budget, security requirement, approved technology}

## Dependencies

- {Dependency 1 — external service, other team, feature that
  must land first}
- Omit if none.

## Migration / Rollback

How will we get from the current state to the new state?
What is the rollback strategy if things go wrong?
Omit if the feature is purely additive with no migration.

## Open Questions

1. {Question — what is unclear and who needs to answer}
2. ...

If readiness is "needs-clarification", this section is
mandatory. If readiness is "ready", omit this section.

## ADRs

- {ADR reference and one-line summary}
- Omit if no architectural decisions were made.
```

## Constraints

- **Read-only** — do not create, modify, or delete any source
  files. The only files you write are the feature spec and
  ADRs.
- **No decomposition** — do not break the feature into epics
  or stories. That's what `/reins-decompose` does.
- **No implementation details** — do not describe how to build
  it. Describe what the feature achieves, not how the code
  looks.
- **No invented requirements** — do not add capabilities the
  feature doesn't ask for. Clarify what's there, don't expand
  scope.
- **Stay grounded** — only reference systems, services, and
  patterns that actually exist.
- **Flag ambiguity, don't resolve it** — if something is
  unclear, put it in Open Questions. The team resolves
  ambiguity, not the agent.
- **Human approved Jira comments** — the comment added in
  Step 6 summarizes content the user already reviewed in
  Steps 3-4. No new information is introduced.