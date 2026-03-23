# Plan — Stage 1: Local Agent Skills

Validate the three-loop workflow using any local agent runtime
(Cursor, Claude Code, Codex CLI, etc.). Zero infrastructure — the
output is a set of tested skills, prompts, and formats that carry
directly into Stage 2 (backend harness, planned after
Stage 1 retrospective).

See `4-architecture-options.md` → Recommendation → Stage 1.

## Goal

Prove (or disprove) that the three-loop workflow produces better,
more reliable output than ad-hoc prompting. Do this at conversation
speed with no backend code.

## Configuration Strategy

Two IDE-agnostic, portable formats cover everything:

- **`AGENTS.md`** — Always-on project context (coding standards,
  architecture, guardrails). Read by Cursor, Claude Code, Codex,
  Copilot, Gemini, Windsurf, and 15+ tools. Already exists.
- **`SKILL.md`** — On-demand procedural workflows. Open standard
  (agentskills.io) supported by 27+ agents. Each workflow loop
  is a skill.

No tool-specific configuration (`.cursor/rules/`, `.cursorrules`,
etc.). Everything works across local agent runtimes.

## What We're Building

- Agent skills (`skills/`) for each workflow loop, installed
  globally via `install.sh`
- Prompt templates embedded in the skills
- Plan format (YAML frontmatter + markdown sections)
- Adherence assessment format and scoring criteria
- Skill feedback loop (lessons → skill improvement)
- Story intake (paste / file / Jira CLI/MCP)

## What We're Validating

- Does the plan-before-implement loop catch design issues early?
- Do the prompt templates generate useful, actionable plans?
- Does the adherence assessment catch real implementation gaps?
- What context does each phase actually need?
- Does sub-agent model routing (capable for planning, fast for
  implementation) work in practice?
- Does the feedback loop measurably improve skill reliability
  over successive runs?

## Deliverables

- [ ] Skill: Loop 1 — Plan generation
- [ ] Skill: Loop 2 — Implementation
- [ ] Skill: Loop 2b — Self-review and adherence assessment
- [ ] Plan format specification
- [ ] Adherence assessment format specification
- [ ] Skill: Retro — feedback capture and skill improvement
- [ ] Story intake working (paste, file, or Jira CLI/MCP)
- [ ] At least 3 stories run through the full workflow
- [ ] Lessons learned: what worked, what didn't, what to change

## Story Intake

The plan skill needs a story (summary, description, acceptance
criteria). How it gets there shouldn't matter — the skill works
with whatever the developer provides. Three options, simplest
first:

**1. Paste into conversation (zero setup)**

The developer copies the Jira ticket content and pastes it
directly when invoking the skill:

```
Developer: /reins-plan plan this:

  ## Summary
  Add input validation to the user registration endpoint

  ## Acceptance Criteria
  - [ ] Email field validated against RFC 5322 format
  - [ ] Password requires minimum 8 chars, ...
```

No tooling required. Works today.

**2. Local file**

Story saved as a markdown file that the skill reads:

```
Developer: /reins-plan plan .reins/stories/OLS-42.md
```

Useful if iterating on the same story across sessions.

**3. Jira CLI or MCP (when available)**

If Jira MCP or CLI (`jira issue view OLS-42`) is configured,
the skill can fetch the story directly:

```
Developer: /reins-plan plan OLS-42
```

The skill tries in order: Jira MCP/CLI → local file →
asks the developer to paste. Graceful fallback, no hard
dependency on any integration.

## Plan Format

YAML frontmatter for machine-parseable metadata, markdown body for
the agent and human reviewer. This format carries directly into
Stage 2 where the backend parses it.

```markdown
---
story_id: OLS-42
summary: Add input validation to user registration
status: draft | approved | rejected
scope: small | medium | large
risk: low | medium | high
files:
  - path: src/api/register.py
    action: modify
    rationale: Add validation calls before processing
  - path: src/api/validators.py
    action: create
    rationale: Dedicated validation module
  - path: tests/test_register_validation.py
    action: create
    rationale: Cover all AC with explicit test cases
---

## Approach

Brief description of the overall implementation strategy.

## Per-Criterion Plan

### AC 1: Email validated against RFC 5322
- **Approach:** Use `email-validator` library in new
  `validators.py` module
- **Location:** `src/api/validators.py:validate_email()`
- **Test:** Parameterized test with valid/invalid email samples

### AC 2: Password strength requirements
- **Approach:** Regex-based validator with clear error messages
- **Location:** `src/api/validators.py:validate_password()`
- **Test:** Boundary cases for each requirement

...

## Risk Assessment

- What could go wrong and how to mitigate it
- Dependencies or unknowns

## Open Questions

- Anything that needs team input before implementation
```

## Adherence Assessment Format

Structured self-review output. The agent scores its own work
against each acceptance criterion.

```markdown
---
story_id: OLS-42
overall_score: 87
verdict: pass | fail | needs_review
criteria:
  - id: 1
    description: Email validated against RFC 5322
    status: PASS
    reference: src/api/validators.py:15-28
    evidence: Uses email-validator library, tested with 12 cases
  - id: 2
    description: Password strength requirements
    status: PASS
    reference: src/api/validators.py:30-45
    evidence: Regex enforces min 8 chars, uppercase, number
  - id: 3
    description: Missing fields return 400
    status: FAIL
    reference: null
    evidence: Error returns 422 (Pydantic default), not 400
---

## Summary

3/4 acceptance criteria met. One criterion requires adjustment
to HTTP status code handling.

## Issues Found

### Issue 1: Wrong HTTP status code for missing fields
- **AC:** Missing required fields return 400
- **Actual:** Returns 422 (Pydantic validation default)
- **Fix:** Override Pydantic exception handler to return 400
- **Severity:** Low — behavior is correct, status code differs

## Test Results

- 15 tests passing, 0 failing
- Coverage: 94% on modified files

## Files Modified vs. Plan

| Planned | Actual | Match |
|---------|--------|-------|
| src/api/register.py (modify) | modified | yes |
| src/api/validators.py (create) | created | yes |
| tests/test_register_validation.py (create) | created | yes |
| — | src/api/exceptions.py (create) | drift |

Drift: `exceptions.py` added for custom error handler. Reasonable
scope addition, not in original plan.
```

## Skill Feedback Loop

Skills should improve over time. Every workflow execution that
hits a problem is a signal — the skill is missing a constraint,
a convention, or context that would have prevented it. This is
the "Toward Zero Interrupts" principle from the design docs:
treat every failure as a structural gap to fix, not just a
one-off correction.

### Mechanism: `reins-retro` Skill

A dedicated skill that runs after any phase. Each core skill's
final output suggests it:

> "When ready: /reins-retro OLS-42"

The `reins-retro` skill:
1. Asks: "Did anything go wrong or need manual correction?"
2. If yes, identifies the structural fix
3. **Directly edits the relevant skill** — adds a constraint,
   refines a step, tightens an instruction
4. Or updates AGENTS.md if the fix is a project-wide convention
5. Shows the diff, gets developer approval

No lessons log, no accumulation. The skill just gets better.
The git history is the record of what changed and why.

Example: after running `reins-retro`, the `reins-implement`
skill gains a new constraint:

```diff
 **Key constraints:**
 - Follow the plan's file list — do not modify unplanned files
   without documenting why
 - Write tests alongside code, not after
+- Write tests for each file before moving to the next file
 - Run the full test suite before declaring done
```

### What Gets Fixed Where

| Signal | Source | Fix target |
|--------|--------|------------|
| Agent went off-plan | Developer correction | Add constraint to skill |
| Review too lenient | Developer noticed missed issue | Tighten review skill |
| Plan missed a file | Implementation discovered it | Improve plan skill's exploration |
| Agent used wrong pattern | Developer rewrote code | Add convention to AGENTS.md |

## Developer Experience

Each workflow phase is a separate skill. The developer triggers
them one at a time, in any order. Files in `.reins/` are the
handoff artifacts between phases.

### Why Separate Skills

- **Context isolation.** Each phase gets a clean context window
  with only what it needs. The implementation agent doesn't carry
  the planning agent's exploration history.
- **Natural pause points.** The developer reviews the plan in
  their editor, maybe overnight, maybe after a discussion. No
  conversation sitting open waiting.
- **Independent retry.** Re-run just the review without
  re-implementing. Re-plan without losing the implementation.
- **Model routing.** Each conversation can use a different model
  — capable model for planning, fast model for implementation.
- **Composable.** Once individual skills work, a combined
  `reins-work-on` skill can chain them with checkpoints (see
  Future below).

### The Skills

| Skill | Phase | What it does |
|-------|-------|--------------|
| `reins-plan` | Loop 1 | Read story, explore codebase, produce plan |
| `reins-implement` | Loop 2 | Follow plan, write code + tests |
| `reins-review` | Loop 2b | Score implementation against AC |
| `reins-retro` | After any | Capture lessons, update skills |

Additional skills as needed:
- `reins-refine` — revise a plan based on developer feedback
- `reins-fix` — address specific review findings
- `reins-work-on` — chain all phases with checkpoints (future)

### Full Flow

```
Developer: /reins-plan plan OLS-42

Agent:
  → reads story from Jira via MCP
  → explores codebase (read-only)
  → produces plan, saves .reins/plans/OLS-42.md
  → prints plan summary
  → "Review the plan. When ready:
     /reins-implement OLS-42"
```

Developer reviews plan in editor. Edits if needed.

```
Developer: /reins-implement OLS-42

Agent:
  → reads plan from .reins/plans/OLS-42.md
  → implements changes, writes tests, runs tests
  → "Tests pass. When ready:
     /reins-review OLS-42"
```

```
Developer: /reins-review OLS-42

Agent:
  → reads AC + git diff + plan
  → runs tests, checks file scope
  → saves .reins/reviews/OLS-42.md
  → "Score: 87/100. PASS. Create PR?"
```

### Re-plan and Retry

If the developer wants the plan revised, they can either edit
the plan file directly and re-run `/reins-plan`, or use
`/reins-refine`:

```
Developer: /reins-refine OLS-42
  "The plan should use the existing validator module
   instead of creating a new one."

Agent: Reading existing plan and your feedback. Revising...
```

If the review finds failures:

```
Developer: /reins-fix OLS-42

Agent: Reading review. 1 failing AC found. Fixing...
```

### Future: `reins-work-on`

Once individual skills are proven, a combined skill chains them
in a single conversation with developer checkpoints:

```
Developer: /reins-work-on work on OLS-42

Agent:
  → [runs reins-plan steps]
  → prints plan
  → "Do you approve this plan? (approve / revise / stop)"

Developer: approve

Agent:
  → [runs reins-implement steps]
  → "Tests pass. Running self-review..."
  → [runs reins-review steps]
  → "Score: 92/100. PASS. Create PR? (yes / no)"
```

This is just orchestration over the same building blocks. The
individual skills do the real work. Build those first, compose
later.

## Skill Design

Each skill is a `SKILL.md` file following the open standard
(agentskills.io). Skills live in `skills/reins-*/` and
are invoked on demand. Start with the three core skills; add
`reins-refine` and `reins-fix` when the core loop is working.

### Core Skills

#### `reins-plan`

**Purpose:** Generate an implementation plan for a Jira story.

**Context the agent needs:**
- Story (pasted, local file, or Jira CLI/MCP): summary,
  description, acceptance criteria
- Repository: AGENTS.md, directory structure, relevant source
  files discovered during exploration

**Context the agent does NOT need:**
- Implementation details from previous stories
- Full file contents of unrelated modules
- Conversation history from other phases

**Output:**
- `.reins/plans/{story_id}.md` in the plan format (YAML
  frontmatter + markdown sections)
- Summary printed to conversation
- Next step instruction for the developer

**Model routing:** Capable model. Planning requires broad codebase
understanding, architectural reasoning, and judgment about scope.

**Key constraints:**
- Read-only — do not modify any files except the plan
- Do not implement anything
- If the story's AC are ambiguous, flag it in Open Questions

#### `reins-implement`

**Purpose:** Implement an approved plan.

**Context the agent needs:**
- The plan from `.reins/plans/{story_id}.md`
- AGENTS.md and coding standards
- Source files listed in the plan's `files:` frontmatter

**Context the agent does NOT need:**
- The Jira story (the plan contains everything relevant)
- Codebase exploration (the plan already identified the files)
- Planning rationale or alternatives considered

**Output:**
- Code changes per the plan
- Tests alongside implementation
- Passing test suite
- Next step instruction for the developer

**Model routing:** Fast model. The plan provides enough direction
that broad reasoning isn't needed. The agent writes focused code
within a well-defined scope.

**Key constraints:**
- Follow the plan's file list — do not modify unplanned files
  without documenting why
- Write tests alongside code, not after
- Run the full test suite before declaring done
- If the plan is wrong or incomplete, stop and say so — do not
  improvise

#### `reins-review`

**Purpose:** Self-review the implementation against acceptance
criteria.

**Context the agent needs:**
- Acceptance criteria (from the plan's frontmatter)
- `git diff` against the base branch
- The plan (to check file scope drift)
- Test results

**Context the agent does NOT need:**
- The full codebase
- Implementation conversation history
- How the code was written (only what was written)

**Output:**
- `.reins/reviews/{story_id}.md` in the adherence format (YAML
  frontmatter + markdown sections)
- Verdict and score printed to conversation

**Model routing:** Capable model. Review requires judgment about
whether AC are truly met, not just syntactic checking.

**Key constraints:**
- Be strict: PASS means fully met, not partially
- Compare files modified against the plan's file list
- Run the test suite independently and include results
- Do not fix anything — report only
- If an AC is ambiguous, score it as `needs_review`

#### `reins-retro`

**Purpose:** Capture lessons and improve skills after each phase.

**Context the agent needs:**
- The skill that just ran (to know what to update)
- Developer feedback (from conversation)
- AGENTS.md (to check if the fix belongs there instead)

**Context the agent does NOT need:**
- Full codebase
- Other stories' history

**Output:**
- Edited skill file (new constraint, refined instruction), or
- Edited AGENTS.md if the fix is a project-wide convention
- Diff shown to developer for approval

**Key constraints:**
- Show the proposed edit before making it
- Distinguish skill-specific fixes from project conventions
- Keep skills under 500 lines — if adding a constraint, check
  if an existing one can be tightened instead of adding new

### Iteration Skills

Added once the core loop works, to smooth the feedback cycles.

#### `reins-refine`

**Purpose:** Revise a plan based on developer feedback.

**Context the agent needs:**
- Existing plan from `.reins/plans/{story_id}.md`
- Developer feedback (from conversation or inline edits in
  the plan file)
- Original Jira story (via MCP)

**Output:** Updated plan file. Same format, new content.

**When to use:** Developer reviewed the plan and wants changes
without starting from scratch. "Use the existing validator
module instead of creating a new one."

#### `reins-fix`

**Purpose:** Address specific findings from a review.

**Context the agent needs:**
- Review from `.reins/reviews/{story_id}.md`
- The plan (for scope reference)
- AGENTS.md and coding standards

**Output:** Targeted code changes addressing failed AC only.

**When to use:** Review found 1-2 failing criteria. Cheaper
than re-running full implementation — focused fix, not redo.

### Future: `reins-work-on`

Chains the core skills in a single conversation with developer
checkpoints. Built once individual skills are proven. See
Developer Experience section above for the interaction model.

## Steps

### Step 0: Project Setup

- Create `skills/reins-plan/SKILL.md` (skeleton)
- Create `skills/reins-retro/SKILL.md` (skeleton)
- Create `.reins/` directory structure (plans, reviews)
- Install globally via `install.sh`

**Done when:** skill files exist in `~/.cursor/skills/`.

### Step 1: Plan Skill + Retro Skill

- Write `reins-plan` skill with full instructions
- Write `reins-retro` skill with full instructions
- Define plan format (markdown sections, no YAML frontmatter
  yet — keep it simple, add structure later)
- Run the plan skill against 1 real story
- Iterate: use `reins-retro` to capture feedback and improve
  `reins-plan` after each run

**Done when:** Plan skill produces a plan that a developer would
approve without major changes. Retro skill successfully edits
the plan skill based on feedback.

### — Checkpoint: validate plan quality —

Run `reins-plan` against the prepared stories. Use `reins-retro`
after each run to refine. This is the highest-feedback phase —
the plan skill will change significantly here. Don't proceed to
implementation until plans are consistently useful.

### Step 2: Implement Skill

- Create `skills/reins-implement/SKILL.md`
- Write `reins-implement` skill with full instructions
- Include model routing instruction (use fast model)
- Run against an approved plan from the checkpoint above
- Iterate on prompt: does it follow the plan? Does it write
  tests? Does it stay in scope?
- Use `reins-retro` to improve the skill as needed
- Compare output quality with and without the plan (baseline)

**Done when:** Implementation skill produces code that passes
tests and stays within the plan's scope.

### Step 3: Review Skill + Adherence Format

- Create `skills/reins-review/SKILL.md`
- Write `reins-review` skill with full instructions
- Define adherence assessment format
- Run against the implementation from Step 2
- Iterate: is the self-review honest? Does it catch real gaps?
  Is it too lenient or too strict?
- Test: intentionally leave an AC unmet and verify the review
  catches it

**Done when:** Review skill produces an adherence report that
accurately reflects implementation quality.

### Step 4: Iteration Skills

- Write `reins-refine` skill (revise plan from feedback)
- Write `reins-fix` skill (targeted fix for review findings)
- Test refine: edit a plan, run refine, verify it incorporates
  feedback without losing the rest
- Test fix: run against a review with 1 failing AC, verify it
  targets only the failure

**Done when:** Refine and fix skills work for common feedback
scenarios.

### Step 5: Full Loop Validation (3+ Stories)

- Run 3+ stories through the complete workflow:
  plan → approve → implement → review
- Run `reins-retro` when something goes wrong
- Mix of story sizes (small, medium)
- Use refine/fix where needed
- Track: time per phase, number of iterations, quality of output
- Track: skills updated via retro, what changed
- Compare: full-loop output vs. ad-hoc "just implement this"
- Compare: story 1 quality vs. story 3 quality (did retro
  edits improve things?)

**Done when:** 3 stories completed and there's evidence of
whether the workflow produces better output than ad-hoc
prompting.

### Step 6: Retrospective

- Write lessons learned document
- Identify what a backend would need to enforce that skills
  can't
- Finalize prompt templates, formats, and scoring criteria
- Decide: is `reins-work-on` worth building, or does the
  backend make it redundant?

**Done when:** clear picture of what worked, what didn't, and
what Stage 2 should look like.
