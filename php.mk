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

# php_tests_worktree — run the test suite against a git worktree's code while
# reusing the already-running local services (MySQL / Redis / Elasticsearch),
# with per-worktree database isolation so parallel worktree runs don't collide
# with each other or the main checkout. bring the main stack up first.
#
#   make php_tests_worktree WORKTREE=/path/to/worktree
#   make php_tests_worktree WORKTREE=/path/to/worktree TESTS=behat
#   make php_tests_worktree WORKTREE=/path/to/worktree COMMAND="php artisan test"
php_tests_worktree: CONTAINER ?= cli
php_tests_worktree: WORKTREE ?= $(PWD)
php_tests_worktree: WORKTREE_SRC = $(abspath $(WORKTREE))
php_tests_worktree: WORKTREE_ID = $(notdir $(WORKTREE_SRC))
php_tests_worktree: DKR_COMPOSE_SRC = $(WORKTREE_SRC)
php_tests_worktree: DB_DATABASE ?= test_$(subst -,_,$(WORKTREE_ID))
php_tests_worktree: TESTS ?= phpunit
php_tests_worktree: COMMAND ?= vendor/bin/$(TESTS)
php_tests_worktree: DKR_COMPOSE_ADDITIONAL_RUN = --no-deps --env DB_DATABASE=$(DB_DATABASE)
php_tests_worktree:
	@test -n "$(WORKTREE)" && test -d "$(WORKTREE_SRC)" || { echo "php_tests_worktree: WORKTREE '$(WORKTREE)' does not exist" >&2; exit 1; }
	@echo "php_tests_worktree: running '$(COMMAND)' against $(WORKTREE_SRC) (db: $(DB_DATABASE))"
	@if [ ! -d "$(WORKTREE_SRC)/vendor" ] || ! cmp -s "$(WORKTREE_SRC)/composer.lock" "$(PWD)/composer.lock"; then echo "php_tests_worktree: composer.lock drift detected - installing dependencies for '$(WORKTREE_ID)'"; $(DKR_COMPOSE_CMD) run --rm --no-deps $(CONTAINER) composer install; else echo "php_tests_worktree: composer.lock matches main checkout - reusing vendor"; fi
	$(DKR_COMPOSE_CMD_RUN)

php_cmd_%: CONTAINER ?= cli
php_cmd_%:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
