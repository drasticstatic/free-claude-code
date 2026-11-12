# AGENTIC DIRECTIVE

> This file is identical to CLAUDE.md. Keep them in sync.

## ⚠ FIRST: sync this clone before you touch anything

```sh
git pull --rebase --autostash
```

Run this at the **start of every session**, before reading deeply or editing. Several agents and
Christopher push to these repos — including Cosmos agents that run unattended while nobody is at the
machine — so a clone can be behind by the time you open it.

**`--autostash` is what makes this safe on a dirty tree.** It stashes uncommitted changes, rebases
onto the remote, then reapplies them. Your in-progress work survives. Without it, `git pull --rebase`
refuses to run and you are tempted into something worse.

Why it matters more than it sounds:

- A stale clone **does not fail early.** It fails at push time, after the work is done, as a
  non-fast-forward rejection — the most expensive moment to discover it.
- The tempting fix at that point is `git push --force`, which discards whatever someone else pushed
  in the meantime. Syncing first removes the temptation.
- If a rebase does conflict, stop and resolve it deliberately. A conflict is information: someone
  else changed the same lines, and you want to know that *before* building on top of them.

**Fresh clone?** Also run `sh scripts/install-hooks.sh` — git hooks are not version-controlled, so
the commit-attribution hook stays inert until this clone is pointed at `.githooks/`. Details:
[`scripts/README.md`](./scripts/README.md).

---

## Before anyone runs this

What upstream `v6.19.6` does by default, as read in its source at `da29b69d` on 2026-11-12 (the full review is in
the code-forked library, under `audits/free-claude-code/`):

- **It listens on every network interface, with authentication off and a well-known default token.** `HOST`
  defaults to `0.0.0.0`, `PROXY_AUTH_ENABLED` to `false` and `ANTHROPIC_AUTH_TOKEN` to `freecc`
  (`src/free_claude_code/config/settings.py` lines 734-744; the auth check returns at once when auth is off,
  `src/free_claude_code/api/dependencies.py` lines 52-53). Any device on the same network could send model requests
  billed to your provider keys.
- **Set these before the first start**, in `~/.fcc/.env` (mode 600) or the process environment:
  - `HOST=127.0.0.1`
  - `PROXY_AUTH_ENABLED=true`
  - `ANTHROPIC_AUTH_TOKEN=` a long random value, never `freecc`
  - `FCC_OPEN_BROWSER=false`, unless a browser tab at every start is wanted
  - `LOG_LEVEL` left at `INFO` (at `DEBUG` whole conversations are written to the log) and every `LOG_RAW_*` flag
    left `false`
  - `MESSAGING_PLATFORM=none` and `ENABLE_WEB_SERVER_TOOLS=false`, for the two reasons below
- **We do not use the one-line installer or `fcc-update`.** Both fetch and run newer code than the reviewed
  revision: the installer asks GitHub for the latest release and runs that release's installer, checked only for
  shell syntax (`scripts/install.sh` lines 1739-1756), and installs from PyPI rather than from this fork;
  `fcc-update` always moves to the latest release the same way (`scripts/update/fcc-update` lines 17-18).
- **We do not enable the messaging bots (Discord, Telegram).** A message that reaches a configured bot starts a Claude
  Code session with `--dangerously-skip-permissions`, so permission checks are off
  (`src/free_claude_code/cli/managed/claude.py` lines 141 and 153).
- **Web search and fetch are on by default** (`ENABLE_WEB_SERVER_TOOLS`, `settings.py` lines 646-648). When a model
  asks, the server itself sends the search query to DuckDuckGo and fetches the address the model picks, from your own
  connection.

---

## CODING ENVIRONMENT

> The bullets below are upstream's guidance as it stood at the fork point. Here, uv and Python are installed only
> in the private working copy, at the versions upstream pins at the reviewed revision (uv >= 0.13.7, Python ==
> 3.14.10), never through `curl ... | sh` and never by "update it to the latest version".


- Install astral uv using "curl -LsSf https://astral.sh/uv/install.sh | sh" if not already installed and if already installed then update it to the latest version
- Install Python 3.14 using `uv python install 3.14` if not already installed
- Always use `uv run` to run files instead of the global `python` command.
- Current uv ruff formatter is set to py314 which has supports multiple exception types without paranthesis (except TypeError, ValueError:)
- Read `.env.example` for environment variables.
- All CI checks must pass; failing checks block merge.
- Add tests for new changes (including edge cases), then run `uv run pytest`.
- Run checks in this order: `uv run ruff format`, `uv run ruff check`, `uv run ty check`, `uv run pytest`.
- Do not add `# type: ignore` or `# ty: ignore`; fix the underlying type issue.
- All 5 checks are enforced in `tests.yml` on push/merge.

## IDENTITY & CONTEXT

- You are an expert Software Architect and Systems Engineer.
- Goal: Zero-defect, root-cause-oriented engineering for bugs; test-driven engineering for new features. Think carefully; no need to rush.
- Code: Write the simplest code possible. Keep the codebase minimal and modular.

## ARCHITECTURE PRINCIPLES (see PLAN.md)

- **Shared utilities**: Put shared Anthropic protocol logic in neutral `core/anthropic/` modules. Do not have one provider import from another provider's utils.
- **DRY**: Extract shared base classes to eliminate duplication. Prefer composition over copy-paste.
- **Encapsulation**: Use accessor methods for internal state (e.g. `set_current_task()`), not direct `_attribute` assignment from outside.
- **Provider-specific config**: Keep provider-specific fields (e.g. `nim_settings`) in provider constructors, not in the base `ProviderConfig`.
- **Dead code**: Remove unused code, legacy systems, and hardcoded values. Use settings/config instead of literals (e.g. `settings.provider_type` not `"nvidia_nim"`).
- **Performance**: Use list accumulation for strings (not `+=` in loops), cache env vars at init, prefer iterative over recursive when stack depth matters.
- **Platform-agnostic naming**: Use generic names (e.g. `PLATFORM_EDIT`) not platform-specific ones (e.g. `TELEGRAM_EDIT`) in shared code.
- **No type ignores**: Do not add `# type: ignore` or `# ty: ignore`. Fix the underlying type issue.
- **Complete migrations**: When moving modules, update imports to the new owner and remove old compatibility shims in the same change unless preserving a published interface is explicitly required.
- **Maximum Test Coverage**: There should be maximum test coverage for everything, preferably live smoke test coverage to catch bugs early

## COGNITIVE WORKFLOW

1. **ANALYZE**: Read relevant files. Do not guess.
2. **PLAN**: Map out the logic. Identify root cause or required changes. Order changes by dependency.
3. **EXECUTE**: Fix the cause, not the symptom. Execute incrementally with clear commits.
4. **VERIFY**: Run ci checks and relevant smoke tests. Confirm the fix via logs or output.
5. **SPECIFICITY**: Do exactly as much as asked; nothing more, nothing less.
6. **PROPAGATION**: Changes impact multiple files; propagate updates correctly.

## SUMMARY STANDARDS

- Summaries must be technical and granular.
- Include: [Files Changed], [Logic Altered], [Verification Method], [Residual Risks] (if no residual risks then say none).

## TOOLS

- Prefer built-in tools (grep, read_file, etc.) over manual workflows. Check tool availability before use.

## Commit attribution (enforced by hook)

Every commit must carry two git trailers:

```
Co-Authored-By: <Agent> · <Engine> · <Provider> [<Model>]                  # direct
Co-Authored-By: <Agent> · <Engine> · <Gateway> · <Provider> [<Model>]      # proxied
<Platform>-Session: <full session URL>
```

Model in **square brackets**, separator is U+00B7 MIDDLE DOT ( · ). Add `<Gateway>` **only when
inference is proxied** — it names what *routed* the request (`NVIDIA NIM`, `OpenRouter`), never who
made the model (`Z.ai`, `Moonshot AI`, `MiniMaxAI`). The field order mirrors the `/model` selector
string, so `anthropic/nvidia_nim/z-ai/glm4.7` transcribes to `NVIDIA NIM · Z.ai [GLM-4.7]` —
read it left to right rather than memorising it. Local runtimes (`Ollama`, `llama.cpp`,
`LM Studio`) have no gateway: the weights ran on your machine, so the runtime is the Provider. The session
trailer is a **separate** line — folding it onto the `Co-Authored-By:` line breaks git trailer
parsing. Use the full session URL, never a truncated prefix. Key varies by platform:
`Claude-Session:` for Claude Code CLI, `Cosmos-Session:` for Cosmos.

`.githooks/commit-msg` rejects non-conforming commits. **Activate it once per clone:**

```sh
sh scripts/install-hooks.sh
```

Human-only commits: `git commit --no-verify`. **Canonical spec — single source of truth. Do not restate the field table locally; link it:**
[`my-template/AGENT-SYNC/README.md`](https://github.com/drasticstatic/my-template/blob/main/AGENT-SYNC/README.md)
