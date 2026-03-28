---
name: reins-spike
description: >-
  Conduct time-boxed research for a Jira Spike. Reads the
  spike's research questions, explores the codebase and
  external sources, evaluates options, and produces an ADR
  with findings and recommendations. Use when the user says
  "spike", "reins-spike", "research", or wants to investigate
  a technical question before implementation.
---

# reins-spike

Conduct focused research for a Spike issue. Produce a
decision record with findings, options, and a recommendation.

## Invocation

The user provides a spike in one of these forms:

1. **Jira key** — `/reins-spike SPIKE-456` (uses `jira-mcp`
   to fetch the spike)
2. **Pasted content** — spike description with research
   questions directly in the conversation

If using Jira MCP and the `cloudId` is unknown, call
`getAccessibleAtlassianResources` to discover it, or ask the
user.

Extract the **spike ID**, **summary**, **research questions**,
and **time-box** from whatever the user provides.

## Step 1: Read Spike Context

- **From Jira** — fetch the spike via `getJiraIssue` with
  `responseContentFormat: "markdown"`. Extract research
  questions from the description. If no clear research
  questions exist, ask the user to define them before
  proceeding.
- **Parent context** — identify the parent Epic/Feature.
  Read related feature spec from `.reins/feature-specs/` and
  ADRs from `.reins/adrs/` if they exist, to understand the
  broader context.
- **Blocking stories** — check which stories this spike
  blocks (from Jira links or the decomposition record) to
  understand what decisions the spike needs to enable.

## Step 2: Research

For each research question:

- **Search the codebase** — look for existing patterns,
  prior implementations of similar functionality, relevant
  tests, and configuration that constrains the options.
- **Search external sources** — use `WebSearch` and
  `WebFetch` to research libraries, APIs, frameworks, and
  documented patterns relevant to the question. Cite sources.
- **Check prior decisions** — search `.reins/adrs/` for ADRs
  on related topics. Check if this question has been partially
  answered before.
- **Evaluate options** — for each question, identify at least
  two viable options (unless the answer is factual, not a
  choice). Assess pros/cons considering: complexity,
  maintainability, performance, compatibility with existing
  patterns, team familiarity.

## Step 3: Draft Findings

Present findings to the user organized by research question:

```
Spike Research: {spike summary}

Q1: {research question}
  Recommendation: {option name}

  | Option    | Pros          | Cons          |
  |-----------|---------------|---------------|
  | Option A  | {pros}        | {cons}        |
  | Option B  | {pros}        | {cons}        |

  Analysis: {2-3 sentence justification}

Q2: {research question}
  ...

Overall recommendation: {summary}

Sources:
  - {URL — what it covers}
  - ...
```

Ask the user to review and confirm or challenge the
recommendations before finalizing.

## Step 4: Write ADR

Write the decision record to
`.reins/adrs/{spike_id}-{slug}.md`:

```markdown
# {Decision Title}

Date: {YYYY-MM-DD}
Spike: {spike_id}
Status: proposed

## Context

What is the situation that requires a decision? What forces
are at play? Reference the parent feature and blocking
stories. 2-4 sentences.

## Research Questions

1. {Question 1}
2. {Question 2}

## Findings

### Q1: {Question}

**Recommendation:** {Option name}

| Option | Pros | Cons |
|--------|------|------|
| {Option A} | {pros} | {cons} |
| {Option B} | {pros} | {cons} |

**Analysis:** {Detailed justification}

### Q2: {Question}
...

## Decision

{What was decided based on the findings}

## Consequences

What becomes easier or harder as a result? How does this
affect the blocked stories?

## References

- {URL — relevance}
```

## Step 5: Update Jira

Add a comment to the spike via `addCommentToJiraIssue`
summarizing:

- Key findings per research question
- Recommendation
- Link to the ADR file
- Impact on blocked stories

If the user confirms the spike is complete, transition it
to "Done" via `transitionJiraIssue` (after calling
`getTransitionsForJiraIssue` to find the right transition
ID). **Ask before transitioning** — the user may want to
keep it open for further discussion.

## Step 6: Report

```
Spike research complete for {spike_id}.

ADR written to .reins/adrs/{spike_id}-{slug}.md
Jira updated with findings.
{if transitioned: Spike transitioned to Done.}

Unblocked stories:
  - {STORY-KEY}: {summary}

Next steps:
  - /reins-story-spec {STORY-KEY}
  - /reins-work-on {STORY-KEY}

— reins
```

## Constraints

- **Read-only for source files** — do not create, modify, or
  delete any source code. The only files you write are ADRs.
- **Cite all external sources** — every external resource
  (docs, blog posts, library READMEs, API references) goes in
  the ADR's References section with a URL. The user needs to
  verify these independently.
- **Time-box awareness** — if the spike specifies a time-box,
  note it at the start and aim to complete within scope. If
  research is going deeper than the time-box allows, present
  what you have and let the user decide whether to extend.
- **No implementation** — recommend an approach, don't build
  it. Code snippets as illustration are fine, but don't write
  production code.
- **Flag uncertainty** — if the evidence is inconclusive, say
  so. A spike that concludes "we need to prototype this" is
  a valid outcome.
- **Human approval for Jira transitions** — ask before
  transitioning the spike status.
- **Signature** — Jira comments end with `— reins`.