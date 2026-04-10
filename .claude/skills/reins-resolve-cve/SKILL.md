---
name: reins-resolve-cve
description: >-
  Resolve a CVE vulnerability issue from Jira. Reads the
  CVE details, assesses impact, and either marks "not
  affected" with a Jira comment and transition, bumps the
  affected dependency, or implements a code fix. Use when
  the user says "cve", "resolve CVE", "reins-resolve-cve",
  or provides a CVE Jira issue.
---

# reins-resolve-cve

Resolve a CVE vulnerability issue tracked in Jira. Read the
advisory, assess whether the project is affected, and take
the appropriate action — close as "not affected", bump the
dependency, or apply a code fix.

## Defaults

| Setting | Value |
|---------|-------|
| Project key | `OLS` (OpenShift Lightspeed Service) |
| Issue type | Vulnerability |

## Invocation

`/reins-resolve-cve {ISSUE-KEY}` — resolve a specific CVE
`/reins-resolve-cve {Jira URL}` — resolve from a URL
`/reins-resolve-cve` — list all open CVEs in the current
sprint across all components

## CLI Tools

This skill uses **acli** (Atlassian CLI). If not
authenticated, run `acli auth login` first.

| Command | Purpose |
|---------|---------|
| `acli jira workitem search --jql "..." --json` | Find CVEs by JQL query |
| `acli jira workitem view {KEY} --json` | Fetch CVE issue details |
| `acli jira workitem comment create --key {KEY} --body "..."` | Post assessment/resolution comment |
| `acli jira workitem transition --key {KEY} --status "..." --yes` | Transition issue to a status |
| `acli jira workitem create --project OLS --type Story ...` | Create a follow-up issue if needed |

## Step 0: Triage Dashboard (no-args only)

When invoked without arguments, show the user what CVEs
exist in the current sprint. Search broadly — do not filter
by component:

```
project = OLS AND type = Vulnerability
  AND sprint in openSprints()
  AND statusCategory = "To Do"
  ORDER BY priority DESC
```

Use `acli jira workitem search` with `--json` and
`--fields "key,summary,assignee,priority,status"`.

The summary encodes the component:
`CVE-YYYY-NNNNN openshift-lightspeed/{component}: {Package}: {Title} [ols-N]`

Known components (extract from the summary path after
`openshift-lightspeed/`):

| Component slug | Repository |
|----------------|------------|
| `lightspeed-service-api-rhel9` | lightspeed-service |
| `lightspeed-operator*` | lightspeed-operator |
| `lightspeed-console*` | lightspeed-console-plugin |

Present a grouped table:

```
CVEs in current sprint ({N} total, {M} unassigned):

lightspeed-service ({count})
  {KEY}  {CVE-ID}  {package}  {priority}  {assignee or "—"}
  {KEY}  {CVE-ID}  {package}  {priority}  {assignee or "—"}

lightspeed-operator ({count})
  {KEY}  ...

(other / unknown) ({count})
  {KEY}  ...
```

Then ask:

```
Options:
  {ISSUE-KEY} — pick a CVE to resolve
  stop        — done
```

**Wait for the user to pick.** Then proceed to Step 1 with
the chosen issue.

## Step 1: Read the CVE Issue

Fetch the issue via
`acli jira workitem view {KEY} --json`.

Parse the data from these locations:

- **CVE ID** — embedded in the `summary` field, e.g.,
  `CVE-2026-33231 openshift-lightspeed/...: NLTK: ...`
- **Affected package** — mentioned in the description's
  `Flaw:` section (the description starts with boilerplate
  — "Security Tracking Issue", "Do not make this issue
  public" — skip to the flaw text after the `---` separator)
- **Vulnerable version range** — in the flaw prose
- **Fix reference** — upstream commit or PR link, if
  mentioned in the flaw text

Then look up severity externally:

- **CVSS score** — use `WebSearch` for the CVE ID on NVD
  (e.g., `CVE-2026-33231 NVD`) to get the severity rating

If the issue is missing a CVE ID or the affected package
is unclear from the flaw text, ask the user to clarify.

## Step 2: Assess Impact

Before checking versions, understand how this repo manages
dependencies. Look for repo-specific context in:
- `.cursor/rules/`, CLAUDE.md, AGENTS.md
- `.cursor/commands/` (e.g., update-deps instructions)
- `Makefile` targets related to requirements/dependencies

This tells you which files represent the shipped dependency
versions (may differ from `uv.lock` — e.g., separately
compiled requirements files for container builds).

Then determine whether this project is affected:

1. **Check if the package is a dependency** — search the
   dependency spec, lock file, and any generated
   requirements files for the package name. Match
   case-insensitively. If the package is absent from all
   of these, the project is **not affected**.
2. **Check the installed version** — find the exact version
   in the lock file AND in any generated/compiled
   dependency files. If they disagree, the files that ship
   in the container are the ones that matter for the
   vulnerability assessment. Compare against the
   vulnerable version range from the advisory.
3. **Check if the vulnerable code path is reachable** — if
   the CVE targets a specific feature or module of the
   package, search the codebase for imports and usage of
   that feature. If the project never calls the affected
   API, it may be **not affected** even if the version
   is in range.
4. **Check transitive dependencies** — if the package isn't
   a direct dependency, check whether it appears as a
   transitive dependency in the lock file or the generated
   dependency files. Trace which direct dependency pulls
   it in.

## Step 3: Present Assessment

Present the finding to the user clearly:

```
CVE Assessment: {CVE-ID}

Package: {package name}
Vulnerable versions: {range}
Installed version: {version from lock / shipped requirements}
Direct dependency: {yes/no — if no, pulled in by {parent}}

Verdict: {NOT AFFECTED / AFFECTED — bump needed /
         AFFECTED — code change needed}

Reasoning:
- {why this verdict — e.g., "package not in dependency tree",
  "installed version is outside vulnerable range",
  "vulnerable API is not used by this project",
  "project uses the affected code path in module X"}
```

Then ask:

```
Options:
  go   — proceed with the resolution
  revise — change the verdict or approach
  stop   — cancel
```

**Wait for the user.** Do NOT act on the verdict without
explicit acknowledgment. The user may have context that
changes the assessment (e.g., the package is used
indirectly, or the feature is enabled in production but
not in tests).

## Step 4: Resolve

Based on the verdict and user acknowledgment:

### Path A: Not Affected

1. Add a comment to the Jira issue:

   ```bash
   acli jira workitem comment create --key {KEY} \
     --body "**Assessment: Not Affected**

   {CVE-ID} targets {package} versions {range}.

   {Reason — one of:}
   - Package is not in the dependency tree.
   - Installed version ({version}) is outside the
     vulnerable range.
   - The vulnerable code path ({specific API/module}) is
     not used by this project.

   No action required."
   ```

2. Transition the issue to **Done**:

   ```bash
   acli jira workitem transition \
     --key {KEY} --status "Done" --yes
   ```

### Path B: Dependency Bump

Check for repo-specific dependency update instructions
(AGENTS.md, `.cursor/commands/`, `Makefile` targets). Use
those to bump the affected package and regenerate any
derived dependency files.

Verify the new version is outside the vulnerable range in
ALL files that ship to production (lock file, generated
requirements/vendor files). If any file still contains the
vulnerable version, investigate why — the generation
process may need fixing. If the latest upstream release is
still vulnerable, stop and tell the user — no fix is
available yet.

Run the repo's verification gates — discover what checks
to run from AGENTS.md, `.cursor/commands/`, or the
Makefile (e.g., format, lint, type-check, unit tests).

Then add a Jira comment with the CVE ID, old version, new
version, and verification status. Ask the user about Jira
transition — if approved, transition via acli.

### Path C: Code Change (Rare)

1. Explain to the user what code change is needed and why.
   This is unusual — confirm the approach before
   implementing.
2. Make the targeted fix, write or update tests, and run
   the repo's verification gates.
3. Add a Jira comment summarizing the code change.
4. Ask the user about Jira transition.

## Step 5: Report

```
CVE {CVE-ID} resolved for {ISSUE-KEY}.

Verdict: {Not Affected / Bumped {package} to {version} /
         Code fix applied}
Jira: {commented / commented + transitioned to {status}}

{If files changed:}
Files changed:
  - {list files}

Ready to commit.
{End if}
```

If the user wants a commit (Path B or C), use message:

```
fix: resolve {CVE-ID} — bump {package} to {version}
```

or for code changes:

```
fix: resolve {CVE-ID} — {brief description}
```

## Constraints

- **Human gate is mandatory** — never act on the verdict
  without the user confirming the assessment. They may
  know things the codebase analysis cannot reveal.
- **Jira transitions** — Path A (Not Affected) transitions
  automatically to Done/Closed with resolution "Won't Do".
  For Paths B and C, ask the user which transition to use.
- **Minimal changes** — bump only the affected package,
  not all dependencies.
- **Verify after every change** — lint, types, and unit
  tests must pass before declaring done.
- **Do not downplay severity** — if the project is
  affected, say so clearly. Do not stretch "not affected"
  reasoning to avoid work.
- **Use acli** — all Jira operations go through the `acli`
  CLI. If a command fails with an auth error, prompt the
  user to run `acli auth login`. Use `--json` for
  machine-readable output and `--yes` to skip interactive
  confirmations on transitions.
