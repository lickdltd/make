#!/bin/sh
#
# Verifies the wiring of the `php_tests_worktree` make target without Docker, so it
# runs anywhere `make` is available. It checks two things:
#
#   1. the rendered recipe (`make -n`) passes the right parameters — the worktree
#      path, the derived per-worktree database name and the default suite command;
#   2. the shell program the recipe runs reuses the already-running stack, redirects
#      only the code mount, provisions an isolated database and handles composer
#      drift — i.e. it needs no changes in the consuming repo.
#
# The behaviour itself (which talks to Docker) is exercised end-to-end separately.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
worktree=/tmp/wt-fixture-test

failures=0

expect() { # description, fixed-string, haystack
	if printf '%s\n' "$3" | grep -qF -- "$2"; then
		echo "ok   - $1"
	else
		echo "FAIL - $1 (expected to find: $2)"
		failures=$((failures + 1))
	fi
}

refute() { # description, fixed-string, haystack
	if printf '%s\n' "$3" | grep -qF -- "$2"; then
		echo "FAIL - $1 (did not expect: $2)"
		failures=$((failures + 1))
	else
		echo "ok   - $1"
	fi
}

# --- 1. the rendered recipe (make -n): parameters passed to the worktree program ---

if ! recipe=$(make -n \
	-f "$repo_root/docker.mk" \
	-f "$repo_root/php.mk" \
	php_tests_worktree WORKTREE="$worktree" 2>&1); then
	echo "FAIL: 'make -n php_tests_worktree' errored:" >&2
	printf '%s\n' "$recipe" >&2
	exit 1
fi

echo "rendered recipe:"
printf '%s\n' "$recipe" | sed 's/^/  | /'
echo

expect "targets the specified worktree"        "WORKTREE='$worktree'"      "$recipe"
expect "derives a per-worktree database name"  "DB='test_wt_fixture_test_3943437479'" "$recipe"
expect "defaults to the phpunit suite"         "COMMAND='vendor/bin/phpunit'" "$recipe"
expect "runs the worktree program"             'sh -eu -c "$PHP_TESTS_WORKTREE"' "$recipe"

# --- 2. the worktree program itself: render the exported variable via make ---

helper=$(mktemp -t php_tests_worktree_helper.XXXXXX)
trap 'rm -f "$helper"' EXIT INT TERM HUP
printf '_wt_script:\n\t@printf %%s "$$PHP_TESTS_WORKTREE"\n' > "$helper"
script=$(make -s -f "$repo_root/docker.mk" -f "$repo_root/php.mk" -f "$helper" _wt_script)

echo
# reuses the already-running stack rather than starting a fresh one
expect "reuses running services (--no-deps)"      "--no-deps"                                    "$script"
refute "does not start a full stack (up)"          "up --abort-on-container-exit"                 "$script"
expect "reuses the running stack's compose files"  "com.docker.compose.project.config_files"      "$script"
expect "pins the running image"                    "{{.Image}}"                                   "$script"
# redirects only the code mount, without editing the consumer's compose
expect "generates an ephemeral override"           "mktemp"                                       "$script"
expect "auto-detects the app dir via composer.json" "composer.json"                               "$script"
# provisions the isolated database (create + grant + migrate)
expect "creates the isolated database"             "CREATE DATABASE IF NOT EXISTS"                "$script"
expect "grants the app user"                       "GRANT ALL PRIVILEGES"                         "$script"
expect "migrates before the suite"                 "artisan migrate --force"                      "$script"
# composer drift handling
expect "compares composer.lock for drift"          "composer.lock"                                "$script"
expect "installs dependencies on drift"            "composer install"                             "$script"

echo
if [ "$failures" -ne 0 ]; then
	echo "php_tests_worktree: $failures assertion(s) FAILED"
	exit 1
fi
echo "php_tests_worktree: all assertions passed"
