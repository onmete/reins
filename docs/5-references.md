# References

Source material and prior art that informed this design.

## ThoughtWorks Future of Software Engineering Retreat (Feb 2026)

- [Reflections on the Future of Software Engineering Retreat](https://www.thoughtworks.com/insights/articles/reflections-future-software-engineering-retreat)
  — Rachel Laycock's key takeaways: cognitive load crisis, supervisory
  engineering middle loop, risk tiering, agent topologies, TDD as the strongest
  form of prompt engineering
- [Where Does the Rigor Go?](https://www.thoughtworks.com/en-ca/insights/blog/agile-engineering-practices/where-does-the-rigor-go)
  — Engineering rigor migrates from code review to specification review
  (upstream) and post-engineering review (downstream)

## OpenAI Engineering Blog

- [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)
  — Ryan Lopopolo (Feb 11, 2026). Origin of the "harness engineering"
  term. Details a five-month experiment building a product with ~1M lines
  of code and zero manually-written lines. Three pillars: context
  engineering, architectural constraints, entropy management. See
  `docs/3-harness-engineering.md` for full research notes.
- [Unlocking the Codex harness: how we built the App Server](https://openai.com/index/unlocking-the-codex-harness/)
  — Technical details of the Codex execution environment (Feb 4, 2026)
- [OpenAI Codex Execution Plans Cookbook](https://cookbook.openai.com/articles/codex_exec_plans)
  — Practical patterns for execution plans as first-class repo artifacts

## Martin Fowler

- [Fragments: February 18](https://martinfowler.com/fragments/2026-02-18.html)
  — Fowler's personal takeaways from the retreat: supervisory engineering
  middle loop, risk tiering as the new core discipline, TDD as the strongest
  form of prompt engineering, agent experience reframe. "More uncertainty
  than certainty" but value in shared understanding of the right questions.

### Exploring Gen AI Series (with Birgitta Böckeler)

- [Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
  — OpenAI's harness for AI-maintained code: context engineering, architectural
  constraints, garbage collection agents. "Our most difficult challenges now
  center on designing environments, feedback loops, and control systems."
- [Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html)
  — The "why loop" (humans iterate on ideas/outcomes) vs. the "how loop"
  (building through artifacts). Humans should be "on the loop," not in it or
  out of it.

## ambient-code.ai Blog Series

- [The "CEO Archetype" is the new 10x](https://ambient-code.ai/2026/01/05/the-ceo-archetype-is-the-new-10x/)
  — When everyone has AI tools, orchestration and judgment become the
  differentiator, not individual technical prowess
- [Toward Zero Interrupts](https://ambient-code.ai/2026/02/18/toward-zero-interrupts-a-working-theory-on-agentic-ai/)
  — Treat every agent interrupt as a structural gap to fix, not a question
  to answer. Three conditions: model intelligence, rich context, robust
  orchestration
- [Structure Dictates Behavior](https://ambient-code.ai/2026/03/10/structure-dictates-behavior-golden-signals-for-agentic-development-teams/)
  — Five golden signals for agentic teams: interrupt rate, autonomous
  completion rate, MTTC, context coverage score, feedback-to-demo cycle time
- [Tokenomics for Code](https://ambient-code.ai/2025/10/06/tokenomics-for-code-value-per-token-in-the-agentic-era/)
  — "Value per token" as the metric that replaces lines of code. Context
  gathering consumes more time than prompting or reviewing.

Full blog list:
- The Path to Vibe Coding for the Enterprise (Sep 23, 2025)
- Evolving what development means (Sep 30, 2025)
- Sowing the Agentic Brownfield (Oct 1, 2025)
- Tokenomics for Code: Value per Token in the Agentic Era (Oct 6, 2025)
- Agentic Development: A Day in the Life (Nov 17, 2025)
- Your Codebase Is Probably Fighting Claude, part 1 (Nov 21, 2025)
- 6 thoughts on my first AI.engineer CODE + AI Native DevCon (Dec 2, 2025)
- Lethain has finally weighed in on AI adoption (Dec 11, 2025)
- What's it doing? A convergence of thought (Dec 27, 2025)
- The "CEO Archetype" is the new 10x (Jan 5, 2026)
- Lessons learned from using Claude in ~anger (Jan 8, 2026)
- Toward Zero Interrupts (Feb 18, 2026)
- Structure Dictates Behavior (Mar 10, 2026)
- We probably need a GPS for Agents (Mar 19, 2026)

## ThoughtWorks Retreat — Additional Concepts

- **Self-healing systems / agent subconscious** — Agents informed by a
  knowledge graph of postmortems and incident data. Production issues often
  get solved by latent knowledge of senior leaders; the challenge is when
  those people aren't available. An "agent subconscious" could surface
  relevant historical context automatically.
- **Superset ledger** — A single source of truth aggregating all changes
  across all systems (logic, infrastructure, database) with rollback
  capability. Generative AI could make this consumable for both agents and
  humans.
- **Programming languages for agents** — Terse, safe languages may prove
  more valuable for AI-generated code. Discussion of whether agent-targeted
  languages need to be human-readable at all, with formal methods and
  property-based testing for verification regardless of language.

## Security Context

- [Glassworm Supply Chain Attack](https://arstechnica.com/security/2026/03/supply-chain-attack-using-invisible-code-hits-github-and-other-repositories/)
  — Invisible Unicode characters in AI-generated commits across 151 GitHub
  repos. Demonstrates that code review (even by seniors) is insufficient
  without tooling/CI guardrails.

## Industry Coverage

- [OpenAI Introduces Harness Engineering — InfoQ](https://www.infoq.com/news/2026/02/openai-harness-engineering-codex/)
  — Industry coverage of the OpenAI harness engineering post with
  Fowler's commentary and architectural diagrams
- [Harness Engineering: The Complete Guide — NxCode](https://www.nxcode.io/resources/news/harness-engineering-complete-guide-ai-agent-codex-2026)
  — Third-party guide with practical Level 1/2/3 harness maturity
  framework and LangChain benchmark evidence
- [Harness Engineering: The Developer Skill That Matters — ComputeLeap](https://www.computeleap.com/blog/harness-engineering-developer-skill-2026/)
  — Evidence that major AI labs (OpenAI, Anthropic, Google DeepMind,
  Anysphere) converged on identical harness architectures independently

## Prior Art

- **Ansible ARC Harness** (`ansible-automation-platform/harness`) — org-wide
  agentic harness with four-level configuration hierarchy (Org → Component →
  Repo → User), 14 SDLC workflows, entry/exit gates, locked guardrails,
  session recording. Configuration layer over existing AI CLIs, not a separate
  backend.
- **agent-tasks-template** (`redhat-vmeperf/agent-tasks-template`)
  — Individual-level gated SDLC process for Claude with multi-step
  verification, auditing, and session lessons. Designed by an AI-skeptical
  engineer as a way to preserve human-in-the-loop discipline. Platform
  agnostic design, initial Claude support. Validates that even skeptics
  independently arrive at gated, multi-step workflows — but the skill
  (understanding *why* each gate exists) matters more than the scaffolding.
- **Cognitive Debt** — Margaret Storey (UoVic): "Velocity without
  understanding is not sustainable." Cognitive debt mitigation strategies
  including regular human checkpoints and proven knowledge-sharing methods.
