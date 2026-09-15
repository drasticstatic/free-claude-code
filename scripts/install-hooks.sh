#!/bin/sh
# Activate this repo's version-controlled git hooks.
#
# Git hooks live in .git/hooks/, which is NOT version-controlled — so a committed
# hook does nothing until each clone is pointed at .githooks/. This script does
# that. Run it once per clone, per machine:
#
#     sh scripts/install-hooks.sh
#
# Safe to re-run. Every agent working in this repo should run it after cloning.
#
# IMPORTANT — ggshield interaction, found 2026-09-14: ggshield (if you use it)
# installs its own secret-scanning pre-commit hook via a GLOBAL
# `core.hooksPath` (~/Library/Application Support/ggshield/git-hooks/ on
# macOS). Setting core.hooksPath to `.githooks` here OVERRIDES that global
# setting at the repo level. If `.githooks/` doesn't also carry its own
# `pre-commit` file that re-chains to ggshield, activating this fleet's
# attribution hook silently disables ggshield's secret scan in this repo,
# with no warning at commit time. `.githooks/pre-commit` in this template
# already does that chaining — if you're vendoring just `.githooks/commit-msg`
# without its sibling `pre-commit`, copy both, not just one.

set -e

cd "$(git rev-parse --show-toplevel)"

if [ ! -d .githooks ]; then
  echo "✗ No .githooks/ directory here. Copy it from my-template first." >&2
  exit 1
fi

chmod +x .githooks/* 2>/dev/null || true

# Refuse to create the silent-ggshield state described above. Pointing
# core.hooksPath at .githooks/ shadows the global hooks directory wholesale, so
# if ggshield is installed but .githooks/ carries no pre-commit, this script
# would be the thing that turns secret scanning off. Documenting that in a
# comment only helps whoever reads the comment; this checks.
if command -v ggshield >/dev/null 2>&1 && [ ! -f .githooks/pre-commit ]; then
  echo "" >&2
  echo "✗ Refusing to install: ggshield is on PATH but .githooks/pre-commit is missing." >&2
  echo "" >&2
  echo "  Setting core.hooksPath would shadow ggshield's global pre-commit hook and" >&2
  echo "  silently disable secret scanning in this repo — no error, no output, just" >&2
  echo "  gone. Copy .githooks/pre-commit from my-template alongside commit-msg:" >&2
  echo "" >&2
  echo "    https://github.com/drasticstatic/my-template/blob/main/.githooks/pre-commit" >&2
  echo "" >&2
  echo "  Override only if you know this repo has no secret-scanning requirement:" >&2
  echo "    ALLOW_NO_GGSHIELD_CHAIN=1 sh scripts/install-hooks.sh" >&2
  echo "" >&2
  [ "${ALLOW_NO_GGSHIELD_CHAIN:-}" = "1" ] || exit 1
  echo "⚠ ALLOW_NO_GGSHIELD_CHAIN=1 set — continuing without the ggshield chain." >&2
fi

PREV=$(git config --get core.hooksPath || echo "")
if [ "$PREV" = ".githooks" ]; then
  echo "✓ core.hooksPath already set to .githooks"
else
  if [ -n "$PREV" ]; then
    echo "⚠ core.hooksPath was '$PREV' — overriding with .githooks"
  fi
  git config core.hooksPath .githooks
  echo "✓ core.hooksPath set to .githooks"
fi

echo ""
echo "Active hooks:"
for h in .githooks/*; do
  [ -f "$h" ] && echo "  · $(basename "$h")"
done
echo ""
echo "commit-msg now enforces the fleet attribution convention."
if [ -f .githooks/pre-commit ]; then
  if command -v ggshield >/dev/null 2>&1; then
    echo "pre-commit chains to ggshield — secret scanning still active."
  else
    echo "pre-commit will chain to ggshield if you install it later."
  fi
fi
echo "See AGENT-SYNC/README.md. Human-only commits: git commit --no-verify"
