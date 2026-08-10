# ssm

AWS_REGION ?= eu-west-1

# Environment segment of the parameter path. Auto-set to the target stem on the
# `_%` variants (e.g. `make ssm_sync_production` -> production); pass SSM_ENV=<env>
# when calling a base target.
SSM_ENV ?=

# Service segment of the parameter path. Defaults to the repo name (git remote
# basename, else the working-directory name) so every repo that inherits these
# helpers targets its own path without configuration.
SSM_REPO_NAME = $(shell git config --get remote.origin.url 2>/dev/null | sed -E 's,.*/,,; s,\.git$$,,')
SSM_SERVICE ?= $(if $(SSM_REPO_NAME),$(SSM_REPO_NAME),$(notdir $(CURDIR)))

# Parameter path convention from RFC #356.1: /ecs/<env>/<service>/<KEY>.
SSM_PATH_PREFIX ?= /ecs/$(SSM_ENV)/$(SSM_SERVICE)

# Committed list of key names (one per line, `#` comments and blank lines ignored)
# that drives ssm_sync and ssm_guard.
SSM_KEYS_FILE ?= $(PWD)/ssm.keys

# Recognisable sentinel written for a freshly-seeded key that has no real value yet.
SSM_PLACEHOLDER ?= PENDING

# ssm_put — create or update a single named SecureString parameter for an
# environment. --overwrite makes it create-or-update.
#
#   KEY=DATABASE_URL VALUE=... make ssm_put_production
#   KEY=DATABASE_URL VALUE=... SSM_ENV=production make ssm_put
SSM_PUT_CMD = aws ssm put-parameter --region $(AWS_REGION) --type SecureString --overwrite --name "$(SSM_PATH_PREFIX)/$(KEY)" --value "$(VALUE)"
ssm_put:
	$(SSM_PUT_CMD)
ssm_put_%: SSM_ENV = $*
ssm_put_%:
	$(SSM_PUT_CMD)

# ssm_sync — reconcile the committed key-name list against SSM for an environment.
# For every key: if the parameter already exists it is left untouched; if it is
# missing a placeholder SecureString is created. Never overwrites an existing value.
define SSM_SYNC
[ -n "$$ENV" ] || { echo "ssm_sync: environment not set (use ssm_sync_<env> or SSM_ENV=<env>)" >&2; exit 1; }
[ -f "$$KEYS_FILE" ] || { echo "ssm_sync: keys file '$$KEYS_FILE' not found" >&2; exit 1; }
created=0; existing=0
while IFS= read -r key || [ -n "$$key" ]; do
  key=$${key%%#*}
  key=$$(printf '%s' "$$key" | tr -d '[:space:]')
  [ -n "$$key" ] || continue
  name="$$PREFIX/$$key"
  if aws ssm get-parameter --region "$$REGION" --name "$$name" >/dev/null 2>&1; then
    echo "ssm_sync: exists, leaving untouched: $$name"
    existing=$$((existing + 1))
  else
    echo "ssm_sync: creating placeholder: $$name"
    aws ssm put-parameter --region "$$REGION" --type SecureString --name "$$name" --value "$$PLACEHOLDER" >/dev/null
    created=$$((created + 1))
  fi
done < "$$KEYS_FILE"
echo "ssm_sync: done ($$created created, $$existing already present)"
endef
export SSM_SYNC

SSM_SYNC_RUN = KEYS_FILE='$(SSM_KEYS_FILE)' PREFIX='$(SSM_PATH_PREFIX)' REGION='$(AWS_REGION)' PLACEHOLDER='$(SSM_PLACEHOLDER)' ENV='$(SSM_ENV)' sh -eu -c "$$SSM_SYNC"
ssm_sync:
	@$(SSM_SYNC_RUN)
ssm_sync_%: SSM_ENV = $*
ssm_sync_%:
	@$(SSM_SYNC_RUN)

# ssm_guard — CI-runnable check that fails when any referenced key still holds the
# sentinel placeholder (or is missing entirely), so a placeholder cannot reach a
# deployed task. Never prints parameter values.
define SSM_GUARD
[ -n "$$ENV" ] || { echo "ssm_guard: environment not set (use ssm_guard_<env> or SSM_ENV=<env>)" >&2; exit 1; }
[ -f "$$KEYS_FILE" ] || { echo "ssm_guard: keys file '$$KEYS_FILE' not found" >&2; exit 1; }
failed=0
while IFS= read -r key || [ -n "$$key" ]; do
  key=$${key%%#*}
  key=$$(printf '%s' "$$key" | tr -d '[:space:]')
  [ -n "$$key" ] || continue
  name="$$PREFIX/$$key"
  if ! value=$$(aws ssm get-parameter --region "$$REGION" --name "$$name" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null); then
    echo "ssm_guard: MISSING: $$name" >&2
    failed=$$((failed + 1))
  elif [ "$$value" = "$$PLACEHOLDER" ]; then
    echo "ssm_guard: unresolved placeholder: $$name" >&2
    failed=$$((failed + 1))
  fi
done < "$$KEYS_FILE"
if [ "$$failed" -ne 0 ]; then
  echo "ssm_guard: $$failed key(s) unresolved for '$$ENV'" >&2
  exit 1
fi
echo "ssm_guard: all keys resolved for '$$ENV'"
endef
export SSM_GUARD

SSM_GUARD_RUN = KEYS_FILE='$(SSM_KEYS_FILE)' PREFIX='$(SSM_PATH_PREFIX)' REGION='$(AWS_REGION)' PLACEHOLDER='$(SSM_PLACEHOLDER)' ENV='$(SSM_ENV)' sh -eu -c "$$SSM_GUARD"
ssm_guard:
	@$(SSM_GUARD_RUN)
ssm_guard_%: SSM_ENV = $*
ssm_guard_%:
	@$(SSM_GUARD_RUN)
