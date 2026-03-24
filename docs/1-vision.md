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

## Code as Disposable Artifact

If the harness is strong enough — tests pass, linters pass, architectural
constraints are enforced mechanically — then the human reviewing
implementation line-by-line adds latency without proportional safety. The
logical shift: **review the behavior contract, not the code.**

This has organizational consequences. Teams that review only behavior
definitions and test suites instead of code+tests get a measurable speedup
across the entire SDLC. When some teams visibly ship faster with equal or
better quality, management asks why others can't. Over time, there is
pressure to adopt behavior-only review where the risk profile allows it.

The adoption gradient is predictable: success correlates inversely with
project size, complexity, and risk. A stateless API gateway? Review only
the OpenAPI spec and test suite. A payment service handling PCI-scoped
data? Human reviews every line.

### The Microservices Renaissance

This pressure creates an architectural incentive. If behavior-only review
works best for small, well-bounded services, teams will decompose systems
to fit. Microservices — which fell partially out of favor due to
operational complexity — become attractive again for different reasons:

- **Hard boundaries.** The network enforces architectural constraints,
  not convention. An agent can't accidentally reach across a service
  boundary the way it can reach across a module boundary.
- **Limited blast radius.** If AI-generated code has subtle issues, the
  damage is contained to one small service, not a monolith.
- **Full-context reasoning.** A 2K-line microservice fits entirely in a
  context window. The agent reasons about the whole thing. A 200K-line
  monolith forces partial views, inconsistent changes, and entropy
  accumulation.
- **Regeneration over refactoring.** When a small service accumulates
  entropy, you can regenerate it from the behavior spec rather than
  patch it. Garbage collection taken to its logical extreme.
- **AI handles the original objection.** The case against microservices
  was operational complexity — too many services, too much boilerplate,
  distributed systems headaches. These are exactly what AI agents
  handle well: scaffolding, wiring, repetitive patterns. Kubernetes
  and service meshes handle the operational side.

The unit of human ownership shifts from "code" to "contract." You own the
API spec, the test suite, the architectural constraints, the deployment
topology. The implementation behind those contracts becomes as disposable
as a CI build artifact — regenerable from the spec if needed.

This is speculative but directional. The stronger the harness becomes, the
less the implementation matters, and the more the architecture must support
safe disposability.

## The Symmetry of Displacement

A common framing: "AI will replace engineers." But displacement is
symmetric. If AI is capable enough to replace most of the engineering
workforce in a corporation, then those same engineers — now armed with
the same AI — can replace the corporation. A single engineer with a
strong harness can build what previously required a team of twenty.

This has two consequences:

**Competition increases everywhere.** The barrier to building software
products drops to near zero. Domain expertise and distribution become
the only defensible moats — the implementation is commoditized. Every
market segment gets more entrants, faster.

**The SaaS oligopoly erodes.** This is already visible. The industry
calls it the "SaaSpocalypse" — $1-2 trillion in SaaS market value
wiped out since January 2026. Salesforce stock dropped 26% YTD with
organic growth slowing to high single digits. Atlassian reported its
first-ever decline in enterprise seat count. Adobe fell ~30%. Per-seat
pricing adoption dropped from 21% to 15% in twelve months, with 70%
of enterprises now demanding usage-based or outcome-based contracts.

The trigger: AI agents that can do the work of 5-15 human users break
the per-seat pricing model. Morgan Stanley noted the structural threat
explicitly: "The rise of AI agents that can operate enterprise software
autonomously poses a structural threat to per-seat SaaS pricing
models." Mid-size companies are acting on this — startup Atonom
replaced a $40K/year Salesforce contract with an AI-built internal CRM
costing $1,200/year, handling lead capture, pipeline tracking, and
reporting with better customization than the off-the-shelf product.

The economics have flipped: when implementation cost was high, buying
made sense. When implementation cost approaches zero, the SaaS tax —
paying for features you don't use, integrations you don't need, and
a vendor's margin — becomes harder to justify.

The implications for engineering organizations:

- **Retention matters more, not less.** Engineers who leave don't
  just take domain knowledge — they take the ability to rebuild your
  product in weeks, not years. The "replaced by AI" engineer is now
  a potential competitor.
- **Harness as institutional knowledge.** The harness — behavior
  specs, architectural constraints, test suites, deployment
  topology — encodes decisions that took years to learn. This
  becomes the durable asset, not the codebase. An engineer can
  regenerate code; they can't easily regenerate the accumulated
  judgment in a well-designed harness.
- **Small teams become viable at larger scale.** OpenAI's proof
  point (3→7 engineers, ~1M lines of code) is the early signal.
  The question is not whether small teams can build large systems
  with AI, but how small. This changes hiring math, org structure,
  and the economics of starting a company.

None of this means engineers become unnecessary. It means the
*scarcity* shifts: from people who can write code to people who can
define what should be built, design systems that constrain AI
effectively, and evaluate whether the output is correct. The CEO of
your backlog framing is not just a workflow improvement — it's a
description of the engineer's durable value.

## Lessons at the End of Each Session

Every workflow execution should produce a feedback loop: what worked, what
didn't, what should change for next time. This isn't just retrospective — it's
the mechanism by which the system improves. The harness gets better because
each execution teaches it something.
