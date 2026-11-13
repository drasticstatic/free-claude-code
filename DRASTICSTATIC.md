# Why drasticstatic keeps this fork

**Free Claude Code** is a local proxy that lets Claude Code and other coding agents use models from other providers
(NVIDIA NIM, OpenRouter, local runtimes and many more) through an Anthropic-compatible API. drasticstatic keeps this
public fork so that the copy we run comes from code someone has read, at a revision that does not move by itself.

## Thank you

This is Ali Khokhar's work (GitHub: Alishahryar1): <https://github.com/Alishahryar1/free-claude-code>. Thank you for
building it and for sharing it. Anything good here is theirs; any change of ours is listed below and is ours to answer
for. Please report problems with the original upstream, and problems with our changes to us.

## The pin

| | |
|---|---|
| Upstream | <https://github.com/Alishahryar1/free-claude-code> |
| Reviewed revision | `da29b69db4cf4854c6d6fb4195e5628db04c219d` (2026-11-09), tag `v6.19.6` |
| Reviewed on | 2026-11-12, by `Alfred · ClaudeCodeCLI · Anthropic [Opus-5.5]`, as text: nothing was installed, built or run |
| Licence | `SPDX-License-Identifier: AGPL-3.0-only` (GNU Affero General Public License v3), unchanged: [`LICENSE`](./LICENSE). Upstream changed it from `MIT` in commit `81cc4e0d` (2026-09-24, "Switch project license to AGPL-3.0-only (#1887)"). Identifiers quoted as upstream states them; this is not legal advice |
| The review | Published in the code-forked library, under `audits/free-claude-code/` ([`drasticstatic/code-forked`](https://github.com/drasticstatic/code-forked)) |
| Antivirus receipt | Pending: the owner scans the staged copy by hand; this line is filled in when he has |
| Runs as | `free-claude-code_private` (private), cloned from this fork |

What the review found that matters before a first start is in the note at the top of [`README.md`](./README.md),
"Before anyone runs this".

## How code moves

```text
upstream  →  this fork, at the reviewed pin  →  free-claude-code_private (the one that runs)
```

- This fork moves to a new upstream revision **only after that revision is reviewed** the same way; the table above
  changes in the same commit.
- Nothing updates itself: no scheduled sync from upstream, no auto-merge, no install-time fetch of newer code. That is
  why we do not use upstream's one-line installer or its `fcc-update` command: both fetch and run newer code than the
  reviewed revision.
- Our own patches, launch wrappers and notes live in the private working copy. None is offered upstream yet.

## Our changes in this fork

| Change | Commits |
|---|---|
| A short note at the top of `README.md`: the pin, this page, and "Before anyone runs this" | `59ae80e1`, `dcf0b9dd`, `9f57f977`; rewritten in the merge `e0c7f292` and after it |
| `.claudeignore`: keeps secrets, dependencies, build output and media out of an agent's reading | `a73423b4` |
| `.githooks/commit-msg` (commit attribution), `.githooks/pre-commit` (chains to a secret scan) and `scripts/install-hooks.sh` | `c8ce96df`, `0824b44c`, `853e46f7`, `58581b73`, `5d4474d9`, `d38fd826`, `225e2fe4` |
| `CLAUDE.md` and `AGENTS.md`: the fleet's rules for agents. Upstream deleted its own versions in `e632c85b` and `4b0eef6f`; ours are kept | `aadc297c`, `e8017387`, `853e46f7`, `58581b73`, `1e4c7bdf`, and the commits after the merge |
| The fleet's public coordination folder for helpers, at the root (one sub-folder per helper, and a README) | `c8ce96df`, `9490ceb4`, `5ccef5b8`, `0824b44c`, `0c7fe73d` |
| `.gitignore`: rotated server logs (`server.*.log`) anywhere, and `.DS_Store` | `8a727135`, `a0fc0534` |
| **Retired:** an edit to the old `api/models/anthropic.py` that let a message's `role` be `"system"`, `"ctx"` or `"msg"` as well as `"user"` and `"assistant"`. It was carried uncommitted from the summer, committed on its own so the record survives, and not ported: upstream removed that file, and its message model at the reviewed revision accepts `"system"` but not `"ctx"` or `"msg"` | `c478fac6` |
| This page | the commit that adds it |

<sub>This page follows the fork front-door rule in [`my-template`](https://github.com/drasticstatic/my-template/blob/main/workflow-templates/FORK-FRONT-DOOR.md).
Written 2026-11-12 by Alfred (Claude Code CLI) for drasticstatic.</sub>
