#!/bin/sh
#
# Verifies the `php_tests_worktree` make target by inspecting the commands it
# would run (`make -n`), so it needs only `make` — no Docker. Checks that the
# flow reuses the already-running services, isolates the database per worktree,
# runs against the worktree's source, and handles composer/vendor drift.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
worktree=/tmp/claude-wt-test

if ! rendered=$(make -n \
	-f "$repo_root/docker.mk" \
	-f "$repo_root/php.mk" \
	php_tests_worktree WORKTREE="$worktree" 2>&1); then
	echo "FAIL: 'make -n php_tests_worktree' errored:" >&2
	printf '%s\n' "$rendered" >&2
	exit 1
fi

echo "rendered commands:"
printf '%s\n' "$rendered" | sed 's/^/  | /'
echo

failures=0

expect() { # description, fixed-string
	if printf '%s\n' "$rendered" | grep -qF -- "$2"; then
		echo "ok   - $1"
	else
		echo "FAIL - $1 (expected to find: $2)"
		failures=$((failures + 1))
	fi
}

refute() { # description, fixed-string
	if printf '%s\n' "$rendered" | grep -qF -- "$2"; then
		echo "FAIL - $1 (did not expect: $2)"
		failures=$((failures + 1))
	else
		echo "ok   - $1"
	fi
}

# AC1 — runs against the specified worktree's code, and runs the suite
expect "mounts the worktree source"          "$worktree"
expect "runs the selected test suite"        "vendor/bin/phpunit"
# AC2 — per-worktree database isolation (name derived + hyphen-sanitised)
expect "isolates the database per worktree"  "DB_DATABASE=test_claude_wt_test"
# AC3 — reuses the already-running services, no duplicate full stack
expect "reuses running services (--no-deps)" "--no-deps"
refute "does not start a full stack (up)"    "up --abort-on-container-exit"
# AC4 — composer/vendor drift handled
expect "compares composer.lock for drift"    "composer.lock"
expect "installs dependencies on drift"      "composer install"

echo
if [ "$failures" -ne 0 ]; then
	echo "php_tests_worktree: $failures assertion(s) FAILED"
	exit 1
fi
echo "php_tests_worktree: all assertions passed"
