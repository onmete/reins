---
name: reins-retro
description: >-
  Analyse a conversation transcript to surface improvement
  opportunities for any skill or AGENTS.md. Reads the
  session, identifies friction patterns, and presents an
  assessment to the user. Use when the user says "retro",
  "reins-retro", or wants to review how a session went.
---

# reins-retro

Read the conversation from any session, identify what could
work better in the skills or conventions that were used, and
present findings to the user.

Any skill that participated in the conversation is in scope
— not just reins skills. The user should not have to
diagnose the problem. The skill reads the evidence, forms
an opinion, and raises it.

## Invocation

`/reins-retro` — analyse the current conversation.

`/reins-retro {transcript_id}` — analyse a past session
from the agent-transcripts folder.

## Step 1: Read the Conversation

If a transcript ID is given, read the JSONL file from the
agent-transcripts folder. Otherwise analyse the current
conversation context.

Skim for the shape of the session: which skills ran, what
the user asked for, where the agent struggled or changed
direction. Don't read every line in detail yet — build a
map first, then drill into the interesting parts.

## Step 2: Identify Improvement Candidates

Scan the conversation for these signals:

- **Corrections** — the user had to redirect the agent,
  reject output, or repeat instructions. A skill's
  instructions may be incomplete or ambiguous.
- **Backtracking** — the agent started down a path, hit a
  wall, and reversed. The skill may lack a precondition
  check or exploration step.
- **Missed context** — the agent didn't look at something
  it should have (existing utils, project conventions,
  related files). A skill may need an explicit exploration
  step.
- **Wrong defaults** — the agent made an assumption that
  was wrong for this project (scope estimate, file
  placement, naming). AGENTS.md or a skill may need a
  tighter default.
- **Friction in handoff** — output from one skill didn't
  flow cleanly into the next (missing fields, format
  mismatch, lost context). The producing skill's output
  format may need a fix.
- **Repeated manual input** — the user had to provide the
  same clarification they've given before. A convention
  should be codified.
- **Scope or quality issues** — the agent over-scoped,
  under-scoped, or produced output that needed significant
  rework.

Not every session has issues. If nothing meaningful
surfaces, say so and stop.

## Step 3: Present the Assessment

For each candidate, present a short assessment block:

```
### Finding {N}: {title}

**Signal:** {what happened in the conversation}
**Root cause:** {why — which skill or convention is lacking}
**Target:** {skill name or AGENTS.md}
**Proposed change:** {one-sentence description of the edit}
**Confidence:** high | medium | low
```

Order findings by confidence (high first). Cap at 5
findings per retro — if there are more, pick the highest
impact ones.

After presenting, ask: "Which of these should I draft an
edit for?" The user may pick all, some, or none.

## Step 4: Draft Edits

For each finding the user selects:

1. **Read the target file** — understand the current
   instructions before changing anything
2. **Draft the edit** — write the specific change:
   - Add a constraint or precondition
   - Tighten an existing instruction
   - Add or reorder a workflow step
   - Adjust output format
3. **Show the proposed diff** — print the before/after so
   the user can review. Do NOT apply yet.

Address findings one at a time so each edit can be
evaluated independently.

## Step 5: Apply on Approval

Only edit the file after the user confirms each change.

## Step 6: Raise a PR

After all approved edits are applied, ask: "Want me to raise
a PR with these improvements?"

If the user agrees:

### Locate the reins repo

The retro may be running from any project that symlinks
reins skills. Edits write through the symlinks, so the
changes are already in the reins repo's working tree.

Resolve the repo path:

```bash
readlink -f "$(which_skill_path)" | sed 's|/.claude/skills/.*||'
```

In practice: find any file you just edited, resolve its
real path, and walk up to the git root. For example, if you
edited `~/.cursor/skills/reins-plan/SKILL.md`, resolve the
symlink to `/home/…/reins/.claude/skills/reins-plan/SKILL.md`
and the repo root is `/home/…/projects/reins`.

All subsequent git and gh commands run in the reins repo,
not the current project.

### Branch, commit, push

1. `cd` into the reins repo root
2. Create a branch: `retro/{short-slug}` (e.g.
   `retro/plan-add-exploration-step`)
3. Stage only the changed skill/convention files
4. Commit with: `fix(skills): {one-line summary of changes}`
   — if multiple skills were touched, list them in the scope:
   `fix(plan,implement): …`
5. Push the branch

### Create the PR

Use `gh pr create` with the `retro-finding` PR template
(`.github/PULL_REQUEST_TEMPLATE/retro-finding.md`). Fill in
the template's sections for each applied finding: Target,
Confidence, Signal, Old Instructions, New Instructions, and
Reason. Duplicate the finding block if multiple findings
were applied.

```bash
gh pr create \
  --title "fix(skills): {summary}" \
  --template retro-finding.md
```

After creation, print:

```
PR created: {PR URL}
```

## What Counts as a Good Edit

- **Specific** — "Check for existing utility modules in
  `src/utils/` before proposing new files" not "Be more
  thorough"
- **Actionable** — the agent can follow it mechanically
- **Minimal** — change the least amount needed
- **Tightens, not bloats** — if an existing instruction
  covers similar ground, refine it rather than adding
  another bullet

## Deciding: Skill vs AGENTS.md

| Signal | Target |
|--------|--------|
| Only affects one skill's behaviour | That skill |
| Affects how all skills operate | AGENTS.md |
| About a specific workflow's steps | That skill |
| About coding style or conventions | AGENTS.md |
| About exploration depth or strategy | That skill |
| About project architecture patterns | AGENTS.md |

When unsure, default to the skill. It's easier to promote
a skill-specific rule to AGENTS.md later than to remove a
project-wide rule that only one skill needed.

## Constraints

- **Analysis first, edits later** — never jump to editing
  without presenting the assessment and getting approval
- **Show before applying** — never edit a skill without
  showing the user the proposed change first
- **Cap at 5 findings** — prioritise by impact. Retros
  that try to fix everything fix nothing.
- **No false positives** — only raise a finding if you can
  point to a specific moment in the conversation. "This
  might be an issue" without evidence is noise.
- **Stay under 500 lines** — if the target skill is
  approaching 500 lines, consolidate or generalise instead
  of appending
- **Preserve voice** — match the writing style of the
  existing skill
- **Git is the log** — do not maintain a changelog or
  "lessons learned" section within the skill
