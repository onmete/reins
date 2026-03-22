# Vision and Philosophy

## The CEO of Your Backlog

The central idea: how an engineer is amplified by AI matters more than whether
they use AI at all. There are two modes:

**Doing the same things faster (bad amplification):**
- Writing boilerplate in 2 minutes instead of 20
- Generating 50 tests instead of writing 5 manually
- Pasting stack traces into AI for quicker diagnosis
- Reviewing 3x more AI-generated code with the same process

The workflow is identical. AI accelerates a step within it. Cognitive load
stays the same or increases.

**Doing things differently (good amplification):**
- Defining behavior specs instead of writing implementation code
- Writing a detailed plan, then evaluating AI-generated approaches against it
- Categorizing changes by risk and applying different review rigor
- Having AI sketch multiple options with trade-off analysis before any code

The workflow fundamentally changes. The engineer moves upstream — defining,
evaluating, deciding — while AI handles implementation mechanics.

## Why Junior vs. Senior is a Red Herring

The "supervisory engineering middle loop" (ThoughtWorks, Feb 2026) is a new
skill for everyone:

- Seniors have domain expertise for knowing *what* to verify, but deeply
  ingrained workflows to unlearn
- Juniors lack domain knowledge but adapt faster to new ways of working
- Neither group is ready-made for the supervisory role

The risk of blindly trusting AI output is not a seniority problem. Experienced
engineers push unreviewed PRs too. The Glassworm supply chain attack (Mar
2026) — invisible Unicode characters in AI-generated commits — was designed to
fool senior code reviewers. Tooling and structural enforcement catch these
things; years of experience alone don't.

Investing in the next generation is non-negotiable. Not doing so puts
organizations in a bad spot 3-5 years from now.

## Structural Enforcement Over Individual Discipline

A process template or harness is a useful scaffold, but someone using it
without understanding *why* each gate exists will hit problems when they
encounter situations the template doesn't cover.

The solution is both:
1. **Structural guardrails** that enforce discipline regardless of experience
   level (locked security policies, mandatory coverage thresholds, entry/exit
   gates on workflows)
2. **Skill development** so engineers understand problem decomposition,
   scoping, and critical evaluation — the thinking behind the guardrails

## Cognitive Load is Increasing

The ThoughtWorks retreat (Feb 2026) found that AI tools are increasing
cognitive load, not reducing it. Developers produce more, faster, but
experience fatigue and burnout from new workflows and concurrent problem
management.

"Velocity without understanding is not sustainable."

The workflow design must account for this: intentional human checkpoints,
scoped decision-making, and clear boundaries between what requires human
judgment and what can be delegated.

## BDD as the Logical Conclusion

When taken to its endpoint, the "CEO of your backlog" model converges on
behavior-driven development: define *what* the system should do through
behavior specs, delegate *how* to the agent, and verify through the BDD suite.

The BDD suite becomes the contract between the human (who defines behavior)
and the agent (who implements it). If behaviors pass, the implementation is
correct — the human doesn't need to care how it got there.

Enterprise adoption of a BDD-only approach is premature, but as a design
direction it aligns with the broader shift from code as the primary artifact
toward verification and outcomes.

## Lessons at the End of Each Session

Every workflow execution should produce a feedback loop: what worked, what
didn't, what should change for next time. This isn't just retrospective — it's
the mechanism by which the system improves. The harness gets better because
each execution teaches it something.
