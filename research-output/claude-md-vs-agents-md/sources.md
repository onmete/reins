# Source Assessments: CLAUDE.md vs AGENTS.md Research

Raw assessment data from Phase 3 (subagent evaluation) and
Phase 4 (multi-hop deepening). This file serves as the audit
trail for the research report.

---

## Batch 1: Core Reference Sources

### Source 1

```
URL: https://claudelab.net/en/articles/claude-code/claude-md-agents-md-complete-guide
Title: The Complete Guide to CLAUDE.md and AGENTS.md
Relevance: 9
Source type: engineering-blog
Recency: 2026-03-26
Key claims:
- [CLAIM] "AAIF under the Linux Foundation formally adopted
  AGENTS.md as an ecosystem standard in 2025" — positions
  AGENTS.md as formal standard
- [CLAIM] "Over 60,000 GitHub repositories use AGENTS.md" —
  adoption signal
- [OPINION/CLAIM] Tool-by-tool matrix (Claude Code: CLAUDE.md
  primary / AGENTS.md fallback; Codex: AGENTS.md with directory
  traversal; Cursor: AGENTS.md root only, no CLAUDE.md) — useful
  summary but conflicts with Cursor docs on nested AGENTS.md and
  observed CLAUDE.md loading
- [OPINION] "AGENTS.md described as YAML + Markdown with strict
  schema" — overstated; real AGENTS.md files are plain Markdown
Follow-up leads:
- AAIF GitHub spec — primary source for what AGENTS.md standardizes
- Cross-check Cursor/Codex sections against vendor docs
```

### Source 2

```
URL: https://cursor.com/docs/context/rules
Title: Rules — Cursor Docs
Relevance: 8
Source type: vendor-docs
Recency: Current (live documentation, accessed 2026-04-13)
Key claims:
- [FACT] Rules are applied at the start of model context;
  persistent guidance across sessions
- [FACT] Four rule surfaces: Project (.cursor/rules), User,
  Team (dashboard), and AGENTS.md as "simple alternative"
- [FACT] AGENTS.md supports nested subdirectories, merged with
  parents; more specific paths take precedence
- [FACT] Precedence on conflict: Team → Project → User Rules
- [FACT] Rules do NOT apply to Cursor Tab or Inline Edit
- [FACT] Project rules support .md/.mdc, frontmatter
  (description, globs, alwaysApply), four activation types
Note: Does NOT mention CLAUDE.md support at all — yet direct
  session observation confirms Cursor loads CLAUDE.md
Follow-up leads:
- cursor.com/llms.txt for related docs
- Team Rules enforcement for organizational adoption
```

### Source 3

```
URL: https://developers.openai.com/codex/guides/agents-md/
Title: Custom instructions with AGENTS.md — OpenAI Codex Docs
Relevance: 10
Source type: vendor-docs
Recency: Current (live documentation, accessed 2026-04-13)
Key claims:
- [FACT] Codex reads AGENTS.md before work; builds instruction
  chain once per run
- [FACT] Discovery: (1) Global under ~/.codex: AGENTS.override.md
  if present, else AGENTS.md; (2) Walk from Git root to cwd,
  checking AGENTS.override.md then AGENTS.md per directory
- [FACT] Merge order: concatenate root→cwd; later files override
  earlier (positional precedence in prompt)
- [FACT] Combined size capped at project_doc_max_bytes (32 KiB)
- [FACT] Configurable fallbacks in ~/.codex/config.toml
  (project_doc_fallback_filenames)
Follow-up leads:
- Advanced config for exact discovery semantics
- agents.md official site for ecosystem context
```

---

## Batch 2: Comparison and Vendor Sources

### Source 4

```
URL: https://vibemeta.app/blog/agents-md-vs-claude-md-vs-cursorrules-2026
Title: AGENTS.md vs CLAUDE.md vs .cursorrules: Which Do You Need?
Relevance: 9
Source type: opinion (with comparison tables)
Recency: 2026-03-08
Key claims:
- [FACT] "AGENTS.md created by OpenAI (Aug 2025) and donated to
  AAIF/Linux Foundation (Dec 2025)"
- [CLAIM] "Claude Code does NOT read AGENTS.md natively — uses
  CLAUDE.md instead" — needs verification against current docs
- [FACT/CLAIM] ".cursorrules deprecated Feb 2025; replaced by
  .cursor/rules/*.mdc with YAML frontmatter"
- [CLAIM] "Vercel benchmarks: well-written AGENTS.md → 100%
  pass on agent evals vs 79% for skills-based approaches" —
  strong claim; original source not verified
- [OPINION] "Maintain AGENTS.md + symlink/duplicate CLAUDE.md
  for multi-tool teams"
Follow-up leads:
- AAIF official spec and tool list for adoption verification
- Claude Code hierarchy confirmation from Anthropic docs
```

### Source 5

```
URL: https://wowhow.cloud/blogs/claude-md-agents-md-cursorrules-ai-coding-config-guide-2026
Title: CLAUDE.md, AGENTS.md, and .cursorrules Complete Guide (2026)
Relevance: 8
Source type: tutorial (with commercial template upsell)
Recency: 2026-03-31
Key claims:
- [CLAIM] "Claude Code reads CLAUDE.md from project root and
  prepends contents as a user message" — differs from Anthropic's
  "system prompt" phrasing
- [CLAIM] "Trend in 2026 is convergence; Claude Code and Cursor
  both read AGENTS.md alongside native configs" — conflicts with
  other sources re: Claude Code
- [FACT] "Large CLAUDE.md consumes ~2,500 tokens for ~2,000
  words" — useful heuristic
- [OPINION] "Ten sections every CLAUDE.md should include"
Note: Compatibility table shows AGENTS.md "Yes (supported)"
  for Claude Code — this is incorrect per GitHub issues
Follow-up leads:
- Cross-check compatibility table vs official docs
- Anthropic engineering: Claude Code best practices
```

### Source 6

```
URL: https://www.claude.com/blog/using-claude-md-files
Title: Using CLAUDE.md files (Anthropic official)
Relevance: 10
Source type: vendor-docs (product blog)
Recency: 2025-11-25
Key claims:
- [FACT] "CLAUDE.md provides persistent project context; can live
  in repo root, parent directories (monorepos), or home folder"
- [CLAIM] "Your CLAUDE.md file becomes part of Claude's system
  prompt; every conversation starts with this context loaded"
- [FACT] "/init analyzes the project and generates a starter
  CLAUDE.md"
- [FACT] "Custom slash commands live as markdown under
  .claude/commands/"
- [OPINION] "Keep CLAUDE.md concise; split into other markdown
  files and reference them; avoid secrets"
Follow-up leads:
- Anthropic engineering posts on context engineering
- code.claude.com settings.json and subagents docs
```

---

## Batch 3: Standard and Meta-Standard Sources

### Source 7

```
URL: https://agentpatterns.ai/standards/agents-md/
Title: AGENTS.md: A README for AI Coding Agents
Relevance: 9
Source type: engineering-blog
Recency: Estimated 2025–2026
Key claims:
- [FACT] "AGENTS.md is markdown at repository root; compatible
  tools load it into agent context at session start"
- [CLAIM] "AGENTS.md is an open standard for project-level agent
  instructions" — interoperability depends on tool implementation
- [FACT] Table mapping tools to file formats (Claude Code →
  CLAUDE.md, Copilot → .github/copilot-instructions.md, etc.)
- [OPINION] "AGENTS.md should be ~100 lines, pointer format
  linking to docs/ — not embedded documentation"
Follow-up leads:
- agents.md canonical site for formal spec
- Claude Code memory docs for loading semantics
```

### Source 8

```
URL: https://www.surfcontext.org/
Title: SurfContext — One Spec. Every AI Coding Tool. (ARDS v3.0)
Relevance: 8
Source type: vendor-docs (product + spec)
Recency: Estimated 2025–2026
Key claims:
- [CLAIM] "Define context once (CONTEXT.md + .context/ +
  surfcontext.json); tools auto-discover generated per-tool files"
- [FACT/CLAIM] Lists five tools each with own format: Claude Code
  (CLAUDE.md), Codex (AGENTS.md), Cursor (.cursorrules), Copilot
  (.github/copilot-instructions.md), Windsurf (.windsurfrules)
- [CLAIM] "Zero lock-in / no dependencies / no build step"
- [FACT] Compatibility table shows generated outputs for all
  major tool formats
Follow-up leads:
- Full spec at surfcontext.org/spec
- Reconcile Cursor's current rules model vs .cursorrules emphasis
```

### Source 9

```
URL: https://cursor.com/learn/customizing-agents
Title: Customizing Agents — Cursor Learn
Relevance: 7
Source type: tutorial (vendor learn path)
Recency: Estimated 2025–2026
Key claims:
- [FACT] "Rules are markdown in .cursor/rules/ and seen by agent
  at start of every conversation"
- [FACT] "Skills use SKILL.md, frontmatter description, loaded
  dynamically when relevant (vs rules always loaded)"
- [OPINION] "Keep rules short, specific, pointer-heavy; avoid
  copying whole style guides"
Follow-up leads:
- cursor.com/docs/rules.md for exact loading order and precedence
- Comparison to AGENTS.md / CLAUDE.md (not centered on this page)
```

---

## Batch 4: Opinion, Academic, and Tutorial Sources

### Source 10

```
URL: https://medium.com/@hui.huang_50580/what-claude-md-cursor-rules-and-agents-md-are-really-for-b56b3ca8a525
Title: What CLAUDE.md, Cursor Rules, and AGENTS.md Are Really For
Relevance: 8
Source type: opinion
Recency: 2026-03-10
Key claims:
- [OPINION] "Official docs describe mechanics; real repos mix
  incompatible concern types in one file" — argues the mess is
  conflation of facts, norms, and progressive detail
- [CLAIM] "The durable design question is what an agent must
  know upfront to enter a codebase safely" — minimum viable
  onboarding frame
- [OPINION] "Separate project memory (facts), rules/norms
  (behavior), and progressive context (load when needed)"
- [FACT] "Vendor positioning: CLAUDE.md for Claude Code;
  .cursor/rules/ for Cursor; AGENTS.md for Codex-style agents"
Follow-up leads:
- Team boundary patterns for splitting upfront vs discovered context
```

### Source 11

```
URL: https://arxiv.org/html/2602.20478v1
Title: Codified Context: Infrastructure for AI Agents in a
  Complex Codebase
Relevance: 9
Source type: academic
Recency: February 2026 (arXiv preprint)
Key claims:
- [FACT/CLAIM] "Single-file manifests do not scale for very large
  codebases; proposes tiered hot/cold context + specialist agents"
  — empirical setting: ~108K-line C# system, 19 agents, 34
  on-demand specs, 283 sessions
- [FACT] "Prior work characterizes manifest contents and prevalence;
  cites low (~5%) repo-level adoption in one surveyed corpus"
- [FACT] "AGENTS.md linked to reduced median runtime and output
  tokens in cited work (Lulla et al., 2026)"
- [CLAIM] "Codified context is load-bearing infrastructure —
  knowledge about code, not just indexed code"
Follow-up leads:
- Santos et al., 2025; Lulla et al., 2026 — primary adoption
  and effectiveness studies
- Open-source companion repository for reproducible patterns
```

### Source 12

```
URL: https://medium.com/data-science-collective/the-complete-guide-to-ai-agent-memory-files-claude-md-agents-md-and-beyond-49ea0df5c5a9
Title: Complete Guide to AI Agent Memory Files
Relevance: 7
Source type: tutorial
Recency: 2026-02-26
Key claims:
- [FACT/CLAIM] "Multiple tools historically used different
  instruction files; fragmentation motivates shared approach"
- [CLAIM] "AGENTS.md is a multi-vendor standard maintained under
  Linux Foundation / AAIF with broad tool support"
- [OPINION] "Keep CLAUDE.md lean (~300 lines); use four sections:
  context, style, commands, architecture"
- [FACT/CLAIM] "Claude Code supports @ imports in CLAUDE.md
  with recursion limits"
- [CLAIM] "Claude Code auto-memory under
  ~/.claude/projects/.../memory/ with MEMORY.md and topic files"
Follow-up leads:
- Per-tool symlink compatibility and .mdc rules
- agents.md official spec for independent adoption validation
```

---

## Phase 4: Multi-Hop Follow-Up Sources

### Source 13

```
URL: https://linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation
Title: Linux Foundation Announces AAIF Formation
Relevance: 10
Source type: official press release
Recency: 2025-12-09
Key claims:
- [FACT] "AAIF announced December 9, 2025 with Anthropic, Block,
  and OpenAI as co-founders"
- [FACT] "OpenAI donated AGENTS.md as one of three flagship
  projects (alongside MCP from Anthropic and Goose from Block)"
- [FACT] "AGENTS.md adopted by 60,000+ open-source projects and
  agent frameworks including GitHub Copilot, Cursor, Codex,
  Devin, Gemini CLI, and VS Code"
```

### Source 14

```
URL: https://github.com/anthropics/claude-code/issues/6235
Title: Feature Request: Support AGENTS.md (Claude Code)
Relevance: 9
Source type: community (GitHub issue)
Recency: August 2025 (opened), active through 2026
Key claims:
- [FACT] "Feature request opened August 2025 for Claude Code
  to read AGENTS.md as fallback to CLAUDE.md"
- [FACT] "3,000+ upvotes and 200+ comments"
- [FACT] "Zero official responses from Anthropic as of March 2026"
- [CLAIM] Community workaround: reference @AGENTS.md inside
  CLAUDE.md or symlink AGENTS.md → CLAUDE.md
```

### Source 15 (Direct Session Observation)

```
URL: N/A — direct observation in Cursor session 2026-04-13
Title: Cursor always_applied_workspace_rules behavior
Relevance: 10
Source type: empirical observation
Recency: 2026-04-13
Key claims:
- [FACT] Cursor loaded CLAUDE.md from workspace root
  (/home/ometelka/projects/reins/CLAUDE.md) as
  always_applied_workspace_rule
- [FACT] Cursor loaded AGENTS.md from workspace root
  (/home/ometelka/projects/reins/AGENTS.md) as
  always_applied_workspace_rule
- [FACT] Cursor loaded CLAUDE.md from parent directory
  (/home/ometelka/projects/CLAUDE.md) as
  always_applied_workspace_rule
- [FACT] Cursor loaded .cursor/rules/ai-memory.mdc as
  always_applied_workspace_rule
Note: This directly contradicts sources [1][10][13][14]
  which state Cursor does not load CLAUDE.md
```

### Source 16 (Cursor Forum Bug Reports)

```
URL: https://forum.cursor.com/t/cursor-loads-claude-md-even-when-the-third-party-rules-toggle-is-turned-off/149974
Title: Cursor loads CLAUDE.md even when the "third party rules"
  toggle is turned off
Relevance: 10
Source type: community (bug report)
Recency: 2026 (exact date unknown — forum page does not render
  via WebFetch)
Key claims:
- [FACT] Cursor loads CLAUDE.md as a "third party rule" — this
  is intentional feature behavior, not a side effect
- [FACT] A "third party rules" toggle exists in Cursor Settings
  to control this loading
- [FACT/BUG] The toggle does not work — CLAUDE.md loads regardless
  of whether third-party rules are disabled
```

```
URL: https://forum.cursor.com/t/changes-to-claude-claude-md-not-captured/149687
Title: Changes to ~/.claude/CLAUDE.md not captured
Relevance: 7
Source type: community (bug report)
Recency: 2026
Key claims:
- [FACT] Cursor only parses ~/.claude/CLAUDE.md on startup
- [FACT] Changes to the file are not reflected without a full
  Cursor restart (Reload Window is not sufficient)
- [FACT] This is a known limitation with no dynamic reload
  mechanism implemented
```

### Source 17 (Augment Code / ETH Zurich reference)

```
URL: https://www.augmentcode.com/guides/how-to-build-agents-md
Title: How to Build Your AGENTS.md (Augment Code)
Relevance: 7
Source type: engineering-blog
Recency: 2026
Key claims:
- [FACT/CLAIM] "ETH Zurich research found human-curated context
  files provide marginal 4% performance gains"
- [FACT/CLAIM] "LLM-generated files reduced task success by ~3%
  and increased costs by 20%"
- [OPINION] "Effective context files require human curation
  focused on what agents cannot infer independently"
Follow-up leads:
- Original ETH Zurich paper for methodology details
```
