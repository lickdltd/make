# php

php_composer_%: CONTAINER ?= cli
php_composer_%: DKR_COMPOSE_ADDITIONAL_RUN = --no-deps

php_composer_install: COMMAND = composer install $(PACKAGE)
php_composer_install:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }

php_composer_update: COMMAND = composer update $(PACKAGE)
php_composer_update:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }

php_tests_%:
	$(DKR_COMPOSE_CMD_UP) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }

# php_tests_worktree — run a repo's test suite against a git worktree's code while
# reusing the already-running local stack (image, compose files, secrets, services),
# with a per-worktree database so parallel worktree runs never collide with each
# other or the main checkout.
#
# It needs ZERO changes in the consuming repo: bring the main stack up as usual
# (e.g. `make dkr_up_local`) and run this from the MAIN checkout, pointing at a
# worktree. It discovers the running cli container, reuses the exact compose files
# and image that created it, and only redirects the code bind-mount to the worktree
# via an auto-generated ephemeral override — main's env_file/secrets are untouched
# (which matters because decrypted env files are gitignored and absent in worktrees).
#
#   make php_tests_worktree WORKTREE=/path/to/worktree
#   make php_tests_worktree WORKTREE=/path/to/worktree TESTS=behat
#   make php_tests_worktree WORKTREE=/path/to/worktree COMMAND="php artisan test"
#
# Knobs (auto-detected unless set):
#   APP_DIR      path to the app (composer.json/vendor) relative to the repo root;
#                auto-detected from the running code mount (e.g. api/laravel).
#   DB_DATABASE  the isolated database name; derived from the worktree path.
#   DB_FRESH=1   drop the isolated database first for a clean slate.
#   DB_SEED=1    also run `php artisan db:seed` after migrating, for suites whose
#                feature tests expect seeded reference data.
define PHP_TESTS_WORKTREE
log() { printf 'php_tests_worktree: %s\n' "$$1" >&2; }
die() { log "$$1"; exit 1; }

if docker compose version >/dev/null 2>&1; then dc="docker compose"; else dc="docker-compose"; fi
tab=$$(printf '\t')
[ -n "$$CLI_SERVICE" ] || CLI_SERVICE=cli

[ -n "$$WORKTREE" ] && [ -d "$$WORKTREE" ] || die "WORKTREE '$$WORKTREE' does not exist"

# 1. find the running cli container for this compose project + service.
cli=$$(docker ps --filter "label=com.docker.compose.project=$$PROJECT" --filter "label=com.docker.compose.service=$$CLI_SERVICE" --format '{{.ID}}' | head -n1)
[ -n "$$cli" ] || die "no running '$$CLI_SERVICE' container in compose project '$$PROJECT' - bring the stack up first (e.g. make dkr_up_local)"

# 2. reuse the EXACT compose files and image the running stack was created from.
cfg=$$(docker inspect "$$cli" --format '{{index .Config.Labels "com.docker.compose.project.config_files"}}')
[ -n "$$cfg" ] || die "could not read the compose config files from the running stack"
files="-f $$(printf '%s' "$$cfg" | sed 's/,/ -f /g')"
image=$$(docker inspect "$$cli" --format '{{.Image}}')

# 3. locate the code mount and its container target. auto-detect it as the
#    shallowest bind mount, INSIDE the checkout, whose source holds composer.json
#    (so home mounts like ~/.composer or ~/.ssh can't be mistaken for the app).
mounts=$$(docker inspect "$$cli" --format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}{{"\t"}}{{.Destination}}{{"\n"}}{{end}}{{end}}')
if [ -n "$$APP_DIR" ]; then
  # normalise: drop a leading ./ and any trailing slashes so '.', 'x/' etc. still
  # match the canonical Docker mount source.
  ad=$${APP_DIR#./}; while [ "$${ad%/}" != "$$ad" ]; do ad=$${ad%/}; done
  if [ -z "$$ad" ] || [ "$$ad" = . ]; then app_host="$$MAIN"; else app_host="$$MAIN/$$ad"; fi
  app_target=$$(printf '%s\n' "$$mounts" | awk -F"$$tab" -v s="$$app_host" '$$1==s{print $$2; exit}')
  [ -n "$$app_target" ] || die "APP_DIR='$$APP_DIR' is not bind-mounted into the running '$$CLI_SERVICE' container"
else
  line=$$(printf '%s\n' "$$mounts" | while IFS="$$tab" read -r src dst; do
    [ -n "$$src" ] || continue
    [ "$$src" = "$$MAIN" ] || [ "$${src#"$$MAIN"/}" != "$$src" ] || continue
    [ -f "$$src/composer.json" ] || continue
    depth=$$(printf '%s' "$$src" | tr -cd / | wc -c | tr -d ' ')
    printf '%s%s%s%s%s\n' "$$depth" "$$tab" "$$src" "$$tab" "$$dst"
  done | sort -n | head -n1 | cut -f2-)
  app_host=$$(printf '%s' "$$line" | cut -f1)
  app_target=$$(printf '%s' "$$line" | cut -f2)
fi
[ -n "$$app_host" ] && [ -n "$$app_target" ] || die "could not locate the app dir (no bind mount under '$$MAIN' with composer.json); pass APP_DIR=<path relative to the repo root>"

# same relative path inside the worktree.
case "$$app_host" in
  "$$MAIN") app_rel='.' ;;
  "$$MAIN"/*) app_rel=$${app_host#"$$MAIN"/} ;;
  *) die "detected app dir '$$app_host' is outside the checkout '$$MAIN'; pass APP_DIR" ;;
esac
wt_app="$$WORKTREE/$$app_rel"
[ -d "$$wt_app" ] || die "the worktree has no app dir at '$$wt_app' (relative path '$$app_rel')"

log "worktree='$$WORKTREE' app='$$app_rel' target='$$app_target' db='$$DB'"
log "reusing the image and running services of compose project '$$PROJECT'"

# 4. ephemeral override: pin the running image + redirect ONLY the code mount to the
#    worktree. compose merges volumes by target (override wins) so the consumer repo
#    needs no compose edits; main's compose still provides env_file/secrets/network.
override=$$(mktemp -t php_tests_worktree.XXXXXX.yaml)
trap 'rm -f "$$override"' EXIT INT TERM HUP
printf 'services:\n  %s:\n    image: %s\n    volumes:\n      - %s:%s\n' "$$CLI_SERVICE" "$$image" "$$wt_app" "$$app_target" > "$$override"

run() { $$dc $$files -f "$$override" -p "$$PROJECT" run --rm --no-deps "$$@"; }

# 5. composer: install into the worktree when its lock drifts from main (or its
#    vendor is missing); otherwise reuse the worktree's vendor for fast re-runs.
if [ ! -d "$$wt_app/vendor" ] || ! cmp -s "$$wt_app/composer.lock" "$$app_host/composer.lock"; then
  log "composer.lock drift or missing vendor - installing dependencies for the worktree"
  run -e ENTRYPOINT_SKIP=true "$$CLI_SERVICE" composer install --no-interaction
else
  log "composer.lock matches the main checkout - reusing the worktree's vendor"
fi

# 6. provision the isolated database: create it + grant the app user, then migrate.
#    the app user usually only has rights on the base schema, so create as root using
#    the running mysql container's OWN root password env - keeping this zero-config.
dbc=$$(docker ps --filter "label=com.docker.compose.project=$$PROJECT" --format '{{.Names}}{{"\t"}}{{.Image}}' | awk -F"$$tab" 'tolower($$2) ~ /mysql|mariadb|percona/ {print $$1; exit}')
if [ -n "$$dbc" ]; then
  appuser=$$(docker exec "$$cli" printenv DB_USERNAME 2>/dev/null || true)
  [ -n "$$appuser" ] || appuser=root
  if [ "$$DB_FRESH" = 1 ] || [ "$$DB_FRESH" = true ]; then
    log "DB_FRESH set - dropping database '$$DB'"
    docker exec -e ISO="$$DB" "$$dbc" sh -c 'mysql -uroot -p"$$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS \`$$ISO\`"' >/dev/null 2>&1 || die "could not drop database '$$DB' via '$$dbc'"
  fi
  log "ensuring isolated database '$$DB' exists and is granted to '$$appuser'"
  docker exec -e ISO="$$DB" -e APPUSER="$$appuser" "$$dbc" sh -c 'mysql -uroot -p"$$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$$ISO\`; GRANT ALL PRIVILEGES ON \`$$ISO\`.* TO \`$$APPUSER\`@\`%\`; FLUSH PRIVILEGES;"' >/dev/null 2>&1 || die "could not create/grant database '$$DB' via '$$dbc' (expects a standard mysql/mariadb image exposing MYSQL_ROOT_PASSWORD)"
  prep="php artisan migrate --force"
  { [ "$$DB_SEED" = 1 ] || [ "$$DB_SEED" = true ]; } && prep="$$prep && php artisan db:seed --force" || true
  log "preparing isolated database '$$DB' ($$prep)"
  run -e ENTRYPOINT_SKIP=true --env DB_DATABASE="$$DB" "$$CLI_SERVICE" sh -c "$$prep"
else
  log "WARNING: no mysql/mariadb/percona service found in project '$$PROJECT' - skipping database provisioning; DB-backed tests may fail"
fi

# 7. run the suite against the worktree's code, in the isolated database.
log "running: $$COMMAND"
if [ "$$ESKIP" = true ]; then
  run -e ENTRYPOINT_SKIP=true --env DB_DATABASE="$$DB" "$$CLI_SERVICE" $$COMMAND
else
  run --env DB_DATABASE="$$DB" "$$CLI_SERVICE" $$COMMAND
fi
endef
export PHP_TESTS_WORKTREE

php_tests_worktree: WORKTREE ?= $(PWD)
php_tests_worktree: WORKTREE_SRC = $(abspath $(WORKTREE))
php_tests_worktree: WORKTREE_ID = $(notdir $(WORKTREE_SRC))
# db name: sanitised worktree basename plus a hash of the full path, so two worktrees
# that share a basename under different parents don't collide and odd characters
# (dots, slashes) can't produce an invalid identifier.
php_tests_worktree: DB_DATABASE ?= $(shell printf 'test_%s_%s' "$$(printf '%s' '$(WORKTREE_ID)' | tr -c 'A-Za-z0-9' '_')" "$$(printf '%s' '$(WORKTREE_SRC)' | cksum | cut -d' ' -f1)")
php_tests_worktree: TESTS ?= phpunit
php_tests_worktree: COMMAND ?= vendor/bin/$(TESTS)
php_tests_worktree: APP_DIR ?=
php_tests_worktree: DB_FRESH ?=
php_tests_worktree: DB_SEED ?=
php_tests_worktree: WORKTREE_ENTRYPOINT_SKIP ?= true
php_tests_worktree:
	@MAIN='$(PWD)' WORKTREE='$(WORKTREE_SRC)' PROJECT='$(DKR_COMPOSE_PROJECT)' \
	CLI_SERVICE='$(CONTAINER)' DB='$(DB_DATABASE)' COMMAND='$(COMMAND)' \
	APP_DIR='$(APP_DIR)' DB_FRESH='$(DB_FRESH)' DB_SEED='$(DB_SEED)' \
	ESKIP='$(WORKTREE_ENTRYPOINT_SKIP)' \
	sh -eu -c "$$PHP_TESTS_WORKTREE"

php_cmd_%: CONTAINER ?= cli
php_cmd_%:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
