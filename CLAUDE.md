# Reins

Structured software development workflow for AI agents. Skills
under `.claude/skills/reins-*/` define each phase.

## Workflow

```
Story → Spec → Plan → [approve] → Implement → PR → Review → Fix → Done
```

The developer approves the plan. Everything after approval is
automatic.

## Skills

| Skill | Purpose |
|-------|---------|
| `/reins-feature-spec` | Feature specification from Jira |
| `/reins-decompose` | Feature → Epics + Stories in Jira |
| `/reins-spike` | Time-boxed research → ADR |
| `/reins-story-spec` | Requirements spec from a story |
| `/reins-plan` | Implementation plan |
| `/reins-implement` | Code + tests from approved plan |
| `/reins-raise-pr` | Create PR with structured description |
| `/reins-review` | Self-review against plan ACs |
| `/reins-fix` | Address review findings |
| `/reins-deliver` | Plan → PR (automatic, no checkpoints) |
| `/reins-work-on` | Full workflow with plan checkpoint |
| `/reins-retro` | Session retrospective → skill edits |

## Artifacts

All artifacts live under `.reins/` in the workspace root:

- `.reins/feature-specs/` — feature specifications
- `.reins/specs/` — story requirement specs
- `.reins/plans/` — implementation plans
- `.reins/adrs/` — architecture decision records
- `.reins/reviews/` — self-review reports

## Conventions

- Wrap prose at 78 characters
- Conventional commits: `type(scope): description`
- PR comments and Jira comments end with `— reins`
- Maximum 2 self-review rounds per story
