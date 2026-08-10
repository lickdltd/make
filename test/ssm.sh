#!/bin/sh
#
# Verifies the wiring of the `ssm.mk` targets without AWS, so it runs anywhere
# `make` is available. It checks two things:
#
#   1. the rendered recipes (`make -n`) build the RFC #356.1 path convention
#      (/ecs/<env>/<service>/<KEY>), pass the right flags, and derive the
#      environment from the target stem;
#   2. the shell programs the recipes run seed missing keys with a placeholder
#      without overwriting existing values (ssm_sync) and fail on an unresolved
#      placeholder (ssm_guard).
#
# The behaviour itself (which talks to AWS) is exercised end-to-end separately.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

# Pin service + region so assertions don't depend on the checkout's git remote.
mk="make -f $repo_root/ssm.mk SSM_SERVICE=api-backend AWS_REGION=eu-west-1"

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

render() { # target [extra make args...]
	if ! out=$($mk -n "$@" 2>&1); then
		echo "FAIL: 'make -n $*' errored:" >&2
		printf '%s\n' "$out" >&2
		exit 1
	fi
	printf '%s' "$out"
}

# --- 1. rendered recipes (make -n) ---------------------------------------------

put=$(render ssm_put_production KEY=DATABASE_URL VALUE=secret)
echo "ssm_put_production recipe:"; printf '%s\n' "$put" | sed 's/^/  | /'; echo
expect "ssm_put calls put-parameter"            "aws ssm put-parameter"                    "$put"
expect "ssm_put uses SecureString"              "--type SecureString"                      "$put"
expect "ssm_put creates-or-updates"             "--overwrite"                              "$put"
expect "ssm_put builds the env/service path"    "/ecs/production/api-backend/DATABASE_URL" "$put"

sync=$(render ssm_sync_staging)
echo "ssm_sync_staging recipe:"; printf '%s\n' "$sync" | sed 's/^/  | /'; echo
expect "ssm_sync derives env from the stem"     "ENV='staging'"                            "$sync"
expect "ssm_sync targets the env/service path"  "PREFIX='/ecs/staging/api-backend'"        "$sync"
expect "ssm_sync passes the sentinel"           "PLACEHOLDER='PENDING'"                    "$sync"
expect "ssm_sync runs the sync program"         'sh -eu -c "$SSM_SYNC"'                    "$sync"

guard=$(render ssm_guard_production)
echo "ssm_guard_production recipe:"; printf '%s\n' "$guard" | sed 's/^/  | /'; echo
expect "ssm_guard derives env from the stem"    "ENV='production'"                         "$guard"
expect "ssm_guard runs the guard program"       'sh -eu -c "$SSM_GUARD"'                   "$guard"

# --- 2. the exported shell programs --------------------------------------------

helper=$(mktemp -t ssm_helper.XXXXXX)
leakdir=$(mktemp -d -t ssm_leak.XXXXXX)
trap 'rm -f "$helper"; rm -rf "$leakdir"' EXIT INT TERM HUP

printf '_sync:\n\t@printf %%s "$$SSM_SYNC"\n_guard:\n\t@printf %%s "$$SSM_GUARD"\n' > "$helper"
sync_script=$($mk -s -f "$helper" _sync)
guard_script=$($mk -s -f "$helper" _guard)

echo
# ssm_sync seeds missing keys with a placeholder, never overwriting existing values
expect "sync checks a key exists first"         "aws ssm get-parameter"                    "$sync_script"
expect "sync seeds missing keys"                "aws ssm put-parameter"                    "$sync_script"
expect "sync seeds a SecureString"              "--type SecureString"                      "$sync_script"
refute "sync never overwrites existing values"  "--overwrite"                              "$sync_script"
expect "sync writes the placeholder value"      'PLACEHOLDER'                              "$sync_script"

echo
# ssm_guard fails on an unresolved placeholder, without leaking values
expect "guard decrypts to read the value"       "--with-decryption"                        "$guard_script"
expect "guard compares against the placeholder" '"$value" = "$PLACEHOLDER"'                "$guard_script"
expect "guard fails when a key is unresolved"   "exit 1"                                   "$guard_script"

# Run the guard end-to-end against a fake `aws` that returns a canary secret, and
# assert the decrypted value never reaches stdout/stderr — a future `echo "$value"`
# leak would be caught here, not just by reading the source.
mkdir "$leakdir/bin"
canary='SECRET-CANARY-9d1f7a'
cat > "$leakdir/bin/aws" <<EOF
#!/bin/sh
# fake \`aws ssm get-parameter\`: always resolves to a real (non-placeholder) value
printf '%s\n' '$canary'
EOF
chmod +x "$leakdir/bin/aws"
printf 'API_KEY\n' > "$leakdir/ssm.keys"
guard_output=$(PATH="$leakdir/bin:$PATH" $mk ssm_guard_production SSM_KEYS_FILE="$leakdir/ssm.keys" 2>&1 || true)

echo
refute "guard never emits the decrypted value"  "$canary"                                  "$guard_output"
expect "guard resolves a real (non-sentinel) value" "all keys resolved"                    "$guard_output"

echo
if [ "$failures" -ne 0 ]; then
	echo "ssm: $failures assertion(s) FAILED"
	exit 1
fi
echo "ssm: all assertions passed"
