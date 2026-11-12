IMPORTANT: Ensure you’ve thoroughly reviewed the [AGENTS.md](AGENTS.md) file before beginning any work.
## ⚠ FIRST: sync this clone with our own `origin`, never with `upstream`

```sh
git pull --rebase --autostash origin
```

Run this at the **start of every session**, before reading deeply or editing. Several agents and
Christopher push to our fork, `origin` (`drasticstatic/free-claude-code`) — including Cosmos agents
that run unattended while nobody is at the machine — so a clone can be behind by the time you open it.

**This rule is for `origin` only. Never pull, merge or rebase from `upstream` as a routine.** This fork
is pinned to an upstream revision that was read before it was merged ([`DRASTICSTATIC.md`](./DRASTICSTATIC.md)).
A sync with `upstream` would bring in code nobody here has reviewed, which is exactly what the pin
exists to prevent. Name the remote, as above, so a bare `git pull` can never follow `upstream` by
accident. A newer upstream revision comes in only as a deliberate merge of one named commit, after
that commit has been reviewed the same way, with `DRASTICSTATIC.md` changed on the same branch.

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
the commit-attribution hook stays inert until this clone is pointed at `.githooks/`. Details: the
header of [`scripts/install-hooks.sh`](./scripts/install-hooks.sh) and of
[`.githooks/commit-msg`](./.githooks/commit-msg).

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

## Working here

- **Attestation.** In repositories Christopher owns, Claude may do the line-by-line review of files the public-lane
  scanner (`scripts/scan-public-lane.sh`) flags and record it in `PUBLIC-ALLOWLIST-ATTESTED.txt`. The officer field
  names the actual reviewer (e.g. `Alfred · ClaudeCodeCLI · Anthropic [Opus-5.5]`), never Christopher's name for a
  review he did not do. When a flagged file names or describes another person or organisation, lean toward
  transparency (a short note they could read), not a silent drop or a gate that stalls publishing. In an
  organisation's repositories, attesting stays with a human who holds the role unless its officers delegate it in
  writing (their `CLAUDE.md`); helpers prepare the attestation lines and hand them over.

---

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
