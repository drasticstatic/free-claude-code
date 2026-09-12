IMPORTANT: Ensure you’ve thoroughly reviewed the [AGENTS.md](AGENTS.md) file before beginning any work.
## Commit attribution (enforced by hook)

Every commit must carry two git trailers:

```
Co-Authored-By: <Agent> · <Engine> · <Provider> [<Model>]
<Platform>-Session: <full session URL>
```

Four fields, model in **square brackets**, separator is U+00B7 MIDDLE DOT ( · ). The session
trailer is a **separate** line — folding it onto the `Co-Authored-By:` line breaks git trailer
parsing. Use the full session URL, never a truncated prefix. Key varies by platform:
`Claude-Session:` for Claude Code CLI, `Cosmos-Session:` for Cosmos.

`.githooks/commit-msg` rejects non-conforming commits. **Activate it once per clone:**

```sh
sh scripts/install-hooks.sh
```

Human-only commits: `git commit --no-verify`. Canonical convention and rationale:
[`my-template/AGENT-SYNC/README.md`](https://github.com/drasticstatic/my-template/blob/main/AGENT-SYNC/README.md)
