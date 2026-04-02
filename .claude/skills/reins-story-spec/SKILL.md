---
name: reins-story-spec
description: >-
  Produce a structured requirements spec from a story. Reads the
  story, assesses clarity, surfaces ambiguities, and writes a
  spec to .reins/specs/. Use when the user says "story spec",
  "reins-story-spec", or wants to clarify requirements before
  planning.
---

# reins-story-spec

Produce a structured requirements specification from a story.
Do NOT plan implementation — this is about what to build, not
how to build it.

## Invocation

The user provides a story in one of these forms:

1. **Pasted content** — story text directly in the conversation
2. **File reference** — `/reins-story-spec .reins/stories/ID.md`
3. **Jira ID** — `/reins-story-spec OLS-42` (requires Jira CLI or
   MCP; fall back to asking the user to paste if unavailable)

Extract the **story ID**, **summary**, and **acceptance
criteria** from whatever the user provides.

## Step 1: Assess Readiness

Read the story and evaluate whether requirements are clear
enough to plan against:

- **Are acceptance criteria present?** A story with no AC or
  only vague AC ("improve performance") cannot produce a
  useful spec. Ask the user to add AC before proceeding.
- **Is the scope bounded?** Can you describe what "done"
  looks like? If the story is open-ended, flag it.
- **Is this the right type?** Implementation stories produce
  specs. Spikes, research, and ADR stories do not — tell the
  user and suggest the appropriate format.

If the story is completely unready (no AC, no clear goal),
stop and tell the user what's missing instead of producing
a hollow spec.

## Step 2: Explore Context

Explore the codebase to ground the spec in reality:

- Read `AGENTS.md`, relevant docs, and source files the story
  likely touches
- Understand existing behavior that the story modifies
- Identify interfaces, contracts, and conventions the change
  must respect
- Note related tests that define current behavior

This is not planning — you are understanding the domain so
you can assess whether the requirements are complete, not
deciding how to implement them.

## Step 3: Clarify

Inspired by spec-kit's `/clarify` phase. For each acceptance
criterion, ask:

- **Edge cases** — what happens at boundaries? Empty input,
  max values, concurrent access, partial failure?
- **Implicit requirements** — does this AC assume something
  not stated? Authentication, authorization, backwards
  compatibility, migration?
- **Ambiguous language** — "should handle errors gracefully"
  means what exactly? Retry? Return 400? Log and continue?
- **Dependencies** — does this AC depend on another AC, an
  external service, or a story that hasn't landed yet?
- **Conflicts** — does this AC contradict another AC or
  existing behavior?

For clear stories, this step is fast — most ACs pass without
questions. For ambiguous stories, this is where the value is.

## Step 4: Write Spec

Write the spec to `.reins/specs/{story_id}.md` using the
format below.

If `.reins/specs/{story_id}.md` already exists, ask the user
whether to overwrite or update.

After writing, print the spec and tell the user:

```
Spec written to .reins/specs/{story_id}.md

Readiness: ready | needs-clarification
{if needs-clarification: list the open questions}

When ready: /reins-plan {story_id}
```

## Spec Format

```markdown
---
story_id: {ID}
summary: {one-line summary}
readiness: ready | needs-clarification
---

## Context

What exists today that this story changes or extends. Ground
this in the codebase — reference actual files, modules,
interfaces. 2-4 sentences.

## Requirements

### AC 1: {criterion text from the story}

**Clarified:** {restate the AC with resolved ambiguity —
  specific, testable, no wiggle room}

**Edge cases:**
- {edge case 1 and expected behavior}
- {edge case 2 and expected behavior}

**Constraints:**
- {constraint this AC must respect — e.g. backwards
  compatibility, performance budget, security requirement}

### AC 2: ...

## Dependencies

- {dependency 1 — external service, other story, migration}
- Omit if none.

## Out of Scope

- {thing that might seem in scope but explicitly is not}
- Omit if obvious.

## Open Questions

1. {question — what is unclear and who needs to answer}
2. ...

If readiness is "needs-clarification", this section is
mandatory. If readiness is "ready", omit this section.
```

## Constraints

- **Read-only** — do not create, modify, or delete any source
  files. The only file you write is the spec itself.
- **No implementation details** — do not describe how to build
  it. No file lists, no approach, no architecture. That's
  what `/reins-plan` does.
- **No invented requirements** — do not add features the story
  doesn't ask for. Clarify what's there, don't expand scope.
- **Stay grounded** — only reference files and patterns that
  actually exist in the codebase.
- **Flag ambiguity, don't resolve it** — if an AC is unclear,
  put it in Open Questions. Do not guess what the author
  meant. The team resolves ambiguity, not the agent.
- **Be honest about readiness** — if the story is clear, say
  "ready" and keep the spec thin. Do not manufacture
  complexity to justify the spec's existence.
