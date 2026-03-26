---
name: reins-plan
description: >-
  Generate an implementation plan for a story. Reads the story
  (pasted, local file, or Jira CLI), explores the codebase, and
  writes a structured plan to .reins/plans/. Use when the user
  says "plan", "reins-plan", or provides a story to plan.
---

# reins-plan

Generate an implementation plan for a story. Do NOT implement
anything.

## Invocation

The user provides a story in one of these forms:

1. **Pasted content** — story text directly in the conversation
2. **File reference** — `/reins-plan plan .reins/stories/ID.md`
3. **Jira ID** — `/reins-plan plan OLS-42` (requires Jira
   CLI or MCP; fall back to asking the user to paste if
   unavailable)

Extract the **story ID**, **summary**, and **acceptance
criteria** from whatever the user provides.

## Step 1: Evaluate the Story

Before planning, critically assess the story itself:

- **Are acceptance criteria present and testable?** If AC are
  missing or vague ("improve performance", "make it better"),
  stop and ask the user to clarify before proceeding.
- **Is this implementation, spike, or research?** If the story
  is exploratory ("investigate why X happens", "evaluate
  options for Y"), say so — it needs a different output than
  an implementation plan. Propose a spike format instead.
- **Is it well-scoped?** After exploring the codebase, assess
  whether this is a single coherent change. Signs it should
  be split:
  - Touches more than 3-4 unrelated areas of the codebase
  - AC span multiple concerns (API + UI + data migration)
  - You can't describe the approach in 2-3 sentences
  - Estimated scope is "large" with high risk
- **Are there hidden prerequisites?** Does this story depend
  on refactoring, infrastructure changes, or other stories
  that should land first?

If any of these checks fail, **stop and report back** instead
of producing a plan. Tell the user what's wrong and suggest
how to fix the story (split it, add AC, reclassify as spike,
etc.). This is more valuable than a plan for a bad story.

## Step 1.5: Check for Spec

If `.reins/specs/{story_id}.md` exists, read it and use the
clarified requirements, edge cases, and constraints as input
to the plan. The spec replaces the raw story AC — plan
against the spec, not the original story text.

If no spec exists, proceed with the raw story AC (the spec
step is optional for clear, well-scoped stories).

## Step 2: Plan

Explore the codebase to understand what the story touches.
Focus on files that will need modification, related tests,
interfaces the story touches, and existing patterns for
similar functionality.

When the change alters implicit behavior (removing overrides,
tightening validation, changing defaults), trace the impact
into tests: search for assertions that pass *because of* the
current behavior, not just assertions *about* the behavior.
These are the tests that will break.

Then write the plan to `.reins/plans/{story_id}.md` using
the format below.

If `.reins/plans/{story_id}.md` already exists, ask the user
whether to overwrite or use `/reins-refine` instead.

After writing, print the plan and tell the user:

```
Note: Planning works best with a capable model (not fast).
Review the plan. When ready: /reins-implement {story_id}
```

## Step 3: ADR (if applicable)

If the plan involves a **non-obvious architectural decision**
— choosing between meaningful alternatives with different
trade-offs — write an ADR to `.reins/adrs/{story_id}-{slug}.md`.

Only create an ADR when:

- There were genuine alternatives considered
- The choice has lasting consequences (not easily reversed)
- Future engineers would ask "why did we do it this way?"

Do NOT create ADRs for routine implementation choices.

### ADR Format

```markdown
# {Decision Title}

Date: {YYYY-MM-DD}
Story: {story_id}
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

After writing, mention the ADR in the plan output:

```
ADR written to .reins/adrs/{story_id}-{slug}.md
```

## Plan Format

```markdown
---
story_id: {ID}
summary: {one-line summary}
status: draft
scope: small | medium | large
risk: low | medium | high
pr:  # added by /reins-raise-pr
files:
  - path: {relative path}
    action: create | modify
    rationale: {why this file}
---

## Approach

Brief description of the overall implementation strategy.
Why this approach over alternatives (1-2 sentences if
non-obvious).

If the story involves logically independent changes (e.g.,
a refactor + a new feature that uses it, or an API change +
a migration), split into separate PRs:

### PR 1: {short title}
{what this PR contains and why it's separate}

### PR 2: {short title}
{what this PR contains, dependencies on PR 1 if any}

If the story is a single coherent change, omit the PR
breakdown.

## Per-Criterion Plan

### AC 1: {criterion text}
- **Approach:** what to do and why
- **Where:** file:function or file:class (no line numbers)
- **Test:** how to verify

### AC 2: ...

## Risk Assessment

- What could go wrong and how to mitigate
- Dependencies or unknowns

## Open Questions

1. {question — what is unclear and what decision is needed}
2. ...

Number each question. Ambiguous AC go here (do NOT guess).
Omit this section if there are no open questions.

## References

- Links to external resources consulted during planning
  (API docs, blog posts, library READMEs, search results)
- Only include if external resources were actually used
- Format: `[title](url) — why it's relevant`
```

## Constraints

- **Read-only** — do not create, modify, or delete any source
  files. The only file you write is the plan itself.
- **No implementation** — do not write code, tests, or
  configs. The plan describes what to do, not how the code
  looks. No line numbers (they go stale), no code snippets
  (the implementer will find a better way). Describe
  behavior and intent, not syntax.
- **Stay grounded** — only reference files and patterns that
  actually exist in the codebase. Do not invent modules or
  assume structure.
- **Flag ambiguity** — if an AC is vague or contradictory,
  put it in Open Questions. Do not assume intent.
- **Cite external sources** — if you consult any external
  resource (API docs, blog posts, web search, library
  READMEs), add it to the References section with a URL.
  The user needs to verify these independently.
