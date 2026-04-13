# CLAUDE.md vs AGENTS.md: Standards, Loading Behavior, and Adoption

*Generated: 2026-04-13 | Sources: 16 | Search queries: 9*

---

## Executive Summary

- **Cursor loads both CLAUDE.md and AGENTS.md.** Direct observation
  in this session confirms Cursor auto-discovers and injects both
  files as always-applied workspace rules — including CLAUDE.md
  from parent directories. This contradicts multiple blog sources
  (VibeMeta, WOWHOW, etc.) that claim Cursor ignores CLAUDE.md.
  Cursor's official docs only document AGENTS.md support; CLAUDE.md
  loading appears to be an undocumented behavior.
- **AGENTS.md is the formal cross-tool standard.** Donated by OpenAI
  to the Linux Foundation's Agentic AI Foundation (AAIF) in December
  2025, AGENTS.md is supported by Codex CLI, GitHub Copilot, Cursor,
  Windsurf, Amp, Devin, Google Jules, and others. 60,000+ GitHub
  repos use it.
- **Claude Code does NOT read AGENTS.md.** A feature request (issue
  #6235) with 3,000+ upvotes has received zero official response
  from Anthropic as of April 2026. Workarounds include `@AGENTS.md`
  references inside CLAUDE.md and symlinks.
- **Neither standard is "winning" — they serve different ecosystems.**
  AGENTS.md dominates multi-tool and open-source projects.
  CLAUDE.md dominates Claude Code users. Cursor supports both, plus
  its own `.cursor/rules/` system. The practical advice is: maintain
  both if your team uses multiple tools.
- **Single-file manifests don't scale.** Academic research (ETH
  Zurich, Feb 2026) shows that for codebases over 100K lines, tiered
  context with specialist agents outperforms monolithic instruction
  files.

---

## Current Landscape

### The Three Competing Formats

| Aspect | AGENTS.md | CLAUDE.md | .cursor/rules/ |
|--------|-----------|-----------|-----------------|
| **Origin** | OpenAI (Aug 2025) → AAIF/Linux Foundation (Dec 2025) | Anthropic (2025) | Cursor (2024–2025) |
| **Format** | Plain Markdown | Plain Markdown | MDC (Markdown + YAML frontmatter) |
| **Governance** | Open standard (AAIF) | Vendor-specific | Vendor-specific |
| **Hierarchy** | Nested subdirectories; override files | User/project/local levels | Glob-scoped; directory organization |
| **Auto-gen** | Manual | `/init` command in Claude Code | `/create-rule` in Cursor |
| **Adoption** | 60,000+ GitHub repos [1][2] | Growing (Claude Code user base) | Cursor user base |

### Tool Compatibility Matrix (April 2026)

| Tool | AGENTS.md | CLAUDE.md | Native Format |
|------|-----------|-----------|---------------|
| **OpenAI Codex CLI** | Primary | No | — |
| **GitHub Copilot** | Yes | No | `.github/copilot-instructions.md` |
| **Cursor** | Yes (documented) | Yes (undocumented) | `.cursor/rules/*.mdc` |
| **Claude Code** | No (requested) | Primary | `.claude/rules/*.md` |
| **Windsurf** | Yes | No | `.windsurfrules` |
| **Google Jules** | Yes | No | — |
| **Gemini CLI** | Partial | No | `GEMINI.md` |
| **Amp (Sourcegraph)** | Yes | No | — |
| **Devin** | Yes | No | — |

### How Cursor Loads Context (Empirically Verified)

Based on official documentation [3] and direct session observation:

**Documented loading hierarchy** (from Cursor docs):
1. Team Rules (highest precedence; Team/Enterprise plans)
2. Project Rules (`.cursor/rules/*.md` and `*.mdc`)
3. User Rules (global Cursor Settings)
4. AGENTS.md (project root + subdirectories)

**Observed behavior in this session** — Cursor auto-discovered
and loaded as `always_applied_workspace_rules`:
1. `/home/ometelka/projects/reins/CLAUDE.md` — workspace root
2. `/home/ometelka/projects/reins/AGENTS.md` — workspace root
3. `/home/ometelka/projects/CLAUDE.md` — parent directory
4. `/home/ometelka/.cursor/rules/ai-memory.mdc` — user-level rule

This confirms that **Cursor does load CLAUDE.md**, walking up
the directory tree to parent directories — a behavior not
mentioned in Cursor's official docs. The parent-directory
walk-up mirrors how Codex CLI discovers AGENTS.md files.

### How Claude Code Loads Context

Per Anthropic's official documentation [4]:

1. `~/.claude/CLAUDE.md` — global defaults (lowest priority)
2. `./CLAUDE.md` — project root (team-shared)
3. `./.claude/rules/*.md` — domain-specific rules
4. `./CLAUDE.local.md` — personal overrides (highest priority)

Claude Code does NOT read AGENTS.md. The community workaround
is to add `@AGENTS.md` inside CLAUDE.md, which imports its
contents via Claude Code's file reference syntax [5].

### How Codex CLI Loads AGENTS.md

Per OpenAI's official documentation [6]:

1. Global: `~/.codex/AGENTS.md` (or `AGENTS.override.md`)
2. Project: Walk from Git root to cwd; one file per directory
3. Later files override earlier (positional precedence)
4. Combined size capped at 32 KiB (`project_doc_max_bytes`)

---

## Industry Patterns & Best Practices

### Convergence on "Context Files as Infrastructure"

Multiple sources describe a shift from treating these files as
optional documentation to treating them as load-bearing project
infrastructure [7][8]. The emerging consensus:

- **Write commands, not descriptions** — "Use functional components
  only" beats "We prefer functional programming patterns" [9]
- **Only include rules that change behavior** — remove anything
  the model already does by default [9]
- **Keep files concise** — a 2,000-word file burns ~2,500 tokens
  per interaction [10]; Anthropic recommends under 300 lines [4]
- **Add rules reactively** — when the agent makes the same mistake
  twice, codify the correction [3][6]
- **Split large projects** — use `.claude/rules/` or nested
  AGENTS.md for domain-specific instructions rather than one
  monolithic file [4][11]

### The "Minimum Viable Onboarding" Frame

Hui Huang (Medium, March 2026) argues that the conceptual mistake
is conflating three concerns in one file [8]:
1. **Project memory** (facts) — what this codebase is
2. **Rules/norms** (behavior) — how to work here
3. **Progressive context** (load when needed) — subsystem details

The recommendation: keep always-loaded files small (facts + norms)
and push subsystem details into scoped rules or skills loaded
dynamically.

### Multi-Tool Team Pattern

For teams using both Claude Code and Cursor (or other tools):

1. Maintain AGENTS.md as the cross-tool source of truth
2. Create CLAUDE.md that references it: add `@AGENTS.md` plus
   any Claude-specific instructions
3. Use `.cursor/rules/` for Cursor-specific scoped rules
4. Optionally: symlink AGENTS.md → `.cursorrules` for legacy
   support (verify format compatibility first)

---

## Opinions & Debate

### "AGENTS.md is the standard" vs "CLAUDE.md is better designed"

**Pro AGENTS.md:**
- Linux Foundation governance gives it institutional legitimacy
- 60,000+ repos and 15+ tools creates strong network effects
- OpenAI, GitHub, Google, Sourcegraph all support it natively
- The "write once, works everywhere" promise resonates

**Pro CLAUDE.md:**
- Anthropic's hierarchy (user/project/local) is more
  sophisticated than AGENTS.md's flat-or-nested model
- `/init` auto-generation lowers the barrier to entry
- Auto-memory features (MEMORY.md under `~/.claude/projects/`)
  extend beyond static instructions
- Claude Code's `@` import syntax enables modular composition

**The gap:** Anthropic has not joined the AGENTS.md ecosystem
despite co-founding the AAIF alongside OpenAI and Block. The
AAIF announcement [2] lists MCP and Goose as Anthropic/Block
contributions but AGENTS.md came solely from OpenAI. The 3,000+
upvote feature request for AGENTS.md support in Claude Code
remains unacknowledged [5].

### "These files don't actually help much"

An ETH Zurich/Augment Code study found that human-curated context
files provide only a marginal 4% performance improvement, while
LLM-generated files actually *reduced* task success by ~3% and
increased costs by 20% [12]. This suggests the files matter most
for project-specific non-obvious knowledge that models can't infer
from the code itself.

### Cursor's Intentional but Buggy CLAUDE.md Support

Multiple authoritative blog posts and comparison guides state that
Cursor does NOT support CLAUDE.md [10][13][14]. However, direct
observation in this session proves otherwise — Cursor auto-loads
CLAUDE.md from the workspace root and parent directories.

A bug report on the Cursor forum (forum.cursor.com/t/149974)
confirms this is **intentional behavior**: "Cursor loads CLAUDE.md
even when the 'third party rules' toggle is turned off." This
reveals that:

1. Cursor treats CLAUDE.md as a "third party rule" — a deliberate
   feature controlled by a toggle in Cursor Settings → Features
2. The bug is that the toggle doesn't work — CLAUDE.md loads
   regardless of the setting
3. A related bug (forum.cursor.com/t/149687) reports that changes
   to `~/.claude/CLAUDE.md` aren't picked up without a full
   Cursor restart — no dynamic reload

The Cursor docs page on Rules [3] makes no mention of CLAUDE.md
but does document AGENTS.md as a first-class "simple markdown
alternative" to `.cursor/rules`. CLAUDE.md loading is an
undocumented feature shipped under the "third party rules"
umbrella — which is why most comparison guides miss it.

---

## Where Things Are Headed

### Near-Term (2026)

- **AGENTS.md will remain the cross-tool standard.** With Linux
  Foundation governance, broad tool support, and 60K+ repos, it
  has too much momentum to displace.
- **Claude Code will likely add AGENTS.md support.** The community
  pressure (3,000+ upvotes) and Anthropic's AAIF co-founder
  status make this a question of when, not if.
- **Cursor will continue supporting multiple formats.** Their
  pragmatic approach — documented AGENTS.md support, undocumented
  CLAUDE.md support, plus their own MDC rules — serves their
  model-agnostic positioning.

### Meta-Standards Emerging

**SurfContext** (surfcontext.org) proposes a write-once approach:
define context in `CONTEXT.md` + `.context/` + `surfcontext.json`,
then auto-generate per-tool files (CLAUDE.md, AGENTS.md,
.cursorrules, etc.) [15]. This is an early-stage effort but
addresses real pain for multi-tool teams.

### Scaling Beyond Single Files

The academic consensus is moving toward tiered architectures for
large codebases [7]:
- **Always-loaded layer**: small manifest (~100 lines) with
  project identity, core commands, and critical constraints
- **Domain-scoped layer**: rules per module or subdirectory
- **On-demand layer**: skills, specs, and documentation loaded
  when the agent needs them (Cursor's Skills model, Claude Code's
  `@` imports)

This maps well to how both Cursor and Claude Code are evolving:
Cursor with its Rules vs Skills distinction [16], Claude Code
with its CLAUDE.md + `.claude/rules/` + `.claude/commands/`
hierarchy [4].

---

## Technical Deep-Dives

### Cursor's Rule Loading Mechanism

Cursor injects rule contents at the start of the model context
window as system-level or user-level messages [3][10]. The rules
are applied to Agent (Chat) only — they do not affect Cursor Tab,
Inline Edit, or other features [3].

MDC frontmatter controls activation:
- `alwaysApply: true` — every session
- `alwaysApply: false` + `description` — Agent decides relevance
- `globs: ["**/*.ts"]` — when matching files are in context
- No frontmatter — manually @-mentioned

AGENTS.md files bypass this MDC system entirely — they're loaded
as plain markdown when present in the project root or
subdirectories [3].

### Codex CLI's Discovery Algorithm

OpenAI documents a precise discovery algorithm [6]:
1. Check `~/.codex/AGENTS.override.md`, then `~/.codex/AGENTS.md`
   (first non-empty wins for global scope)
2. Walk directory tree from Git root to cwd
3. At each directory: check `AGENTS.override.md`, then
   `AGENTS.md`, then `project_doc_fallback_filenames`
4. At most one file per directory
5. Concatenate all found files (root→cwd order)
6. Stop when combined size hits `project_doc_max_bytes` (32 KiB)

The `project_doc_fallback_filenames` config option (in
`~/.codex/config.toml`) can be set to include `CLAUDE.md` or
any other filename, enabling cross-tool compatibility [6].

### Token Economics

Context files consume tokens on every interaction. A 2,000-word
file uses roughly 2,500 tokens [10]. With typical context windows
of 128K–200K tokens, this is manageable for a single file but adds
up with multiple rules, skills, and referenced files. The practical
ceiling is ~500 lines for always-loaded content before the signal-
to-noise ratio degrades.

---

## Key Trends

1. **AGENTS.md as the lingua franca** — supported by 3+ major
   tools (Codex, Copilot, Cursor), governed by Linux Foundation,
   60K+ repos. The closest thing to an industry standard. (Sources:
   [1][2][6][13])
2. **Tool-specific files persist alongside the standard** — every
   tool still has a native format (CLAUDE.md, .cursor/rules/,
   .windsurfrules) and these aren't going away. The pattern is
   AGENTS.md as baseline + tool-specific extensions. (Sources:
   [3][4][10][13][14])
3. **Context engineering is a skill, not just a file** — the
   shift from "dump everything into one file" to structured,
   scoped, dynamically-loaded context mirrors the evolution from
   monolithic to modular architectures. (Sources: [7][8][16])
4. **Anthropic is the notable holdout** — Claude Code's lack
   of AGENTS.md support is the biggest gap in cross-tool
   interoperability, despite Anthropic co-founding the AAIF.
   (Sources: [2][5][13])

---

## Evidence Gaps & Open Questions

- **Cursor's CLAUDE.md support is intentional but undocumented.**
  A forum bug report (t/149974) confirms Cursor loads CLAUDE.md
  as a "third party rule" — the bug is that the toggle to disable
  it doesn't work. No changelog entry or official docs mention this
  feature. It's unclear when it was added or whether it will be
  formally documented.
- **Will Anthropic add AGENTS.md support?** The 3,000+ upvote
  feature request has zero official response. Anthropic's AAIF
  co-founder status suggests alignment, but the product team has
  not committed.
- **How do nested AGENTS.md files interact with CLAUDE.md in
  Cursor?** If both are loaded, what's the precedence? The
  observed behavior puts them at the same level
  (always_applied_workspace_rules) but conflict resolution is
  undocumented.
- **Does the 4% improvement finding hold?** The ETH Zurich study
  [12] tested general context files; highly specific files (gotchas,
  non-obvious conventions) may show larger effects. No replication
  study exists.
- **SurfContext viability** — interesting meta-standard concept
  but very early stage; no adoption metrics available.

---

## Sources

1. [The Complete Guide to CLAUDE.md and AGENTS.md](https://claudelab.net/en/articles/claude-code/claude-md-agents-md-complete-guide) — engineering-blog, 2026-03-26
2. [Linux Foundation Announces AAIF Formation](https://linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation) — official press release, 2025-12-09
3. [Cursor Docs: Rules](https://cursor.com/docs/context/rules) — vendor-docs, current
4. [Using CLAUDE.md files (Anthropic blog)](https://www.claude.com/blog/using-claude-md-files) — vendor-docs, 2025-11-25
5. [Claude Code Issue #6235: AGENTS.md Support](https://github.com/anthropics/claude-code/issues/6235) — community, 2025-08
6. [OpenAI Codex: Custom Instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md/) — vendor-docs, current
7. [Codified Context: Infrastructure for AI Agents (arXiv 2602.20478)](https://arxiv.org/html/2602.20478v1) — academic, 2026-02
8. [What CLAUDE.md, Cursor Rules, and AGENTS.md Are Really For](https://medium.com/@hui.huang_50580/what-claude-md-cursor-rules-and-agents-md-are-really-for-b56b3ca8a525) — opinion, 2026-03-10
9. [CLAUDE.md Best Practices: Write Files That Actually Work](https://www.heyuan110.com/posts/ai/2026-03-05-claude-code-claudemd-best-practices/) — tutorial, 2026-03-05
10. [CLAUDE.md, AGENTS.md, and .cursorrules Complete Guide (WOWHOW)](https://wowhow.cloud/blogs/claude-md-agents-md-cursorrules-ai-coding-config-guide-2026) — tutorial, 2026-03-31
11. [Claude Code Issue #31005: AGENTS.md + Skills Support](https://github.com/anthropics/claude-code/issues/31005) — community, 2026
12. [How to Build Your AGENTS.md (Augment Code)](https://www.augmentcode.com/guides/how-to-build-agents-md) — engineering-blog, 2026
13. [AGENTS.md vs CLAUDE.md vs .cursorrules (VibeMeta)](https://vibemeta.app/blog/agents-md-vs-claude-md-vs-cursorrules-2026) — opinion, 2026-03-08
14. [AGENTS.md Guide 2026 (vibecoding.app)](https://vibecoding.app/blog/agents-md-guide) — tutorial, 2026
15. [SurfContext — One Spec. Every AI Coding Tool.](https://www.surfcontext.org/) — vendor-docs, 2025–2026
16. [Cursor Learn: Customizing Agents](https://cursor.com/learn/customizing-agents) — vendor-docs, current
