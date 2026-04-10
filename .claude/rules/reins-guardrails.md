# Reins Guardrails

These rules apply to all Reins workflow phases.

## Plan Before Code

Never generate implementation code without an approved plan in
`.reins/plans/`. If no plan exists, stop and tell the user to
run `/reins-plan` first.

## Artifacts Location

All Reins artifacts go under `.reins/` in the workspace root:
- `.reins/feature-specs/` — feature specifications
- `.reins/specs/` — story requirement specs
- `.reins/plans/` — implementation plans
- `.reins/adrs/` — architecture decision records
- `.reins/reviews/` — self-review reports

## Review Limits

Maximum 2 self-review rounds per story. After round 2, remaining
issues are left for the human reviewer.

## No Silent Overwrites

When a plan, spec, or review file already exists, ask before
overwriting. Show what changed.

## Commit Standards

Use conventional commit format: `type(scope): description`.
Keep commits atomic — one logical change per commit.
