---
name: reins-decompose
description: >-
  Decompose a specified Feature into Epics and Stories in Jira.
  Reads the feature spec from .reins/feature-specs/, proposes a
  full decomposition tree, and creates issues in Jira after
  human approval. Use when the user says "decompose",
  "reins-decompose", "break down feature", or wants to turn a
  feature spec into actionable work items.
---

# reins-decompose

Decompose a Feature into Epics, Stories, and Spikes. The
feature must already have a spec in `.reins/feature-specs/`.
If it doesn't, tell the user to run `/reins-feature-spec`
first.

**Critical rule: never create, edit, or transition Jira issues
without explicit human approval.** Present the full
decomposition tree and wait for the user to approve before
touching Jira.

## Invocation

`/reins-decompose {feature_id}`

The feature ID must match a spec file at
`.reins/feature-specs/{feature_id}.md`.

This skill uses **acli** (Atlassian CLI) for all Jira
operations. If not authenticated, run `acli auth login`
first.

## Step 1: Read Context

- **Feature spec** — read
  `.reins/feature-specs/{feature_id}.md`. If it doesn't exist
  or its readiness is "needs-clarification", stop and tell the
  user.
- **ADRs** — read any `.reins/adrs/{feature_id}-*.md` files
  for architectural decisions that shape the decomposition.
- **Feature from Jira** — fetch via
  `acli jira workitem view {KEY} --json` to get current
  state, existing children (epics/stories already
  linked), and any fields not captured in the spec.
- **Codebase** — read `AGENTS.md` and relevant architecture
  docs to understand component boundaries, service ownership,
  and existing patterns that affect how work is scoped.

## Step 2: Propose Decomposition

Produce a full decomposition tree following these principles:

### Epics
- Each Epic represents a **logical work stream** — a
  cohesive area of the feature that can be developed and
  delivered somewhat independently.
- Epic summary should be clear and descriptive.
- Epic description captures scope boundary from the feature
  spec.
- Epic acceptance criteria are derived from the feature
  spec's success criteria and scope.

### Stories
- Each Story is a **concrete, implementable unit of work**
  with testable acceptance criteria.
- Stories should be completable in **1-3 days**.
- Each Story has:
  - **Summary** — clear, action-oriented title
  - **Acceptance criteria** — specific, testable, no wiggle
    room (these become the input for `/reins-story-spec`
    and `/reins-plan`)
  - **Dependencies** — other stories that must land first
  - **Size** — S / M / L rough estimate
- Order stories within each Epic by dependency (what must be
  built first).

### Spikes
- Create a Spike when **research is needed before a story
  can be written or implemented**.
- Each Spike has:
  - **Summary** — what question needs answering
  - **Research questions** — numbered, specific
  - **Time-box** — how long to spend (typically 0.5-1 day)
  - **Blocks** — which stories depend on this spike's output
- Spikes are executed via `/reins-spike`.

### Quality Checks
Before presenting the tree, self-check:

- **Balanced sizing** — if one Epic has 12+ stories and
  another has 1-2, the boundaries are probably wrong. Flag
  this for the user.
- **Complete coverage** — every item in the feature spec's
  "In Scope" section should map to at least one story.
  Flag any gaps.
- **No orphan dependencies** — if Story B depends on Story
  A, both must exist in the tree. If a dependency is on
  something outside this feature, note it explicitly.
- **Spikes before stories** — if a spike blocks a story,
  the spike must appear earlier in the ordering.

## Step 3: Present for Human Review

Print the full decomposition tree in a readable format:

```
Decomposition for {feature_id}: {feature summary}

Epic 1: {Epic title}
  {Epic description — 1-2 sentences}
  AC: {number} criteria

  Stories:
    1. {Story title}  [S/M/L]
       AC: {list AC inline or count}
       Depends on: {none | Story N}

    2. {Story title}  [S/M/L]
       ...

  Spikes:
    1. {Spike title}  [time-box]
       Questions: {count}
       Blocks: Story {N}

Epic 2: {Epic title}
  ...

Summary:
  Epics: {N}  Stories: {N}  Spikes: {N}
  Estimated total: {S/M/L/XL}
```

Then present the checkpoint:

```
Options:
  approve  — create all issues in Jira
  revise   — tell me what to change
  stop     — save locally, create in Jira later
```

**Wait for the user.** If "revise", incorporate feedback and
re-present. Loop until approved or stopped.

Do NOT proceed to Step 4 without explicit approval.

## Step 4: Create in Jira

After approval, create issues via `acli`:

1. **Create Epics** — under the parent Feature:

   ```bash
   acli jira workitem create \
     --project OLS --type Epic \
     --summary "{title}" \
     --description-file /tmp/epic-desc.md \
     --parent {feature_id} --json
   ```

2. **Create Stories** — under each Epic. Include summary,
   description with acceptance criteria, and parent link:

   ```bash
   acli jira workitem create \
     --project OLS --type Story \
     --summary "{title}" \
     --description-file /tmp/story-desc.md \
     --parent {EPIC-KEY} --json
   ```

3. **Create Spikes** — under the relevant Epic, same as
   stories but with `--type Spike` (or `--type Task` if
   Spike type is not available — ask the user).
4. **Add dependency links** — if the Jira project supports
   issue links (blocks/is-blocked-by), add them between
   dependent stories.

Report each created issue as it's created:

```
Created: EPIC-101 — {title}
Created: STORY-201 — {title} (under EPIC-101)
Created: SPIKE-301 — {title} (under EPIC-101)
...
```

If any creation fails, report the error and continue with
the remaining issues. Do not roll back what was already
created.

## Step 5: Save Decomposition Record

Write the approved decomposition to
`.reins/feature-specs/{feature_id}-decomposition.md`:

```markdown
---
feature_id: {ID}
date: {YYYY-MM-DD}
epics: {count}
stories: {count}
spikes: {count}
---

## Decomposition

{The same tree format shown to the user in Step 3, but
with Jira issue keys added}

## Traceability

| Feature Spec Section | Jira Issue(s) |
|---|---|
| {In Scope item 1} | STORY-201, STORY-202 |
| {In Scope item 2} | STORY-203 |
| ... | ... |
```

## Step 6: Report

```
Decomposition complete for {feature_id}.

Created in Jira:
  Epics: {N} ({keys})
  Stories: {N}
  Spikes: {N}

Decomposition saved to:
  .reins/feature-specs/{feature_id}-decomposition.md

Next steps:
  - For spikes: /reins-spike {SPIKE-KEY}
  - For stories: /reins-story-spec {STORY-KEY}
    or /reins-work-on {STORY-KEY}
```

## Constraints

- **Human gate is mandatory** — never create, edit, or
  transition Jira issues without explicit user approval.
  This is the most important constraint in this skill.
- **Read-only for source files** — do not create, modify, or
  delete any source code. The only files you write are the
  decomposition record and any updates to the feature spec.
- **No implementation details** — stories describe what to
  achieve, not how the code should look. Acceptance criteria
  are behavioral ("API returns 404 when resource not found"),
  not implementational ("add a check in handler.go line 42").
- **Stay grounded** — reference actual systems, services, and
  components from the codebase. Do not invent modules.
- **Respect existing work** — if the Feature already has
  Epics or Stories in Jira, acknowledge them. Ask the user
  whether to incorporate, replace, or work alongside them.