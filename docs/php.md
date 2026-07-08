# php

> This also requires you to have [docker.mk](../docker.mk) installed.

* [setup](#setup)
    * [docker compose file](#docker-compose-file)
* [commands](#commands)
    * [composer install](#composer-install)
    * [composer update](#composer-update)
    * [tests](#tests)
    * [tests against a worktree](#tests-against-a-worktree)

## setup

### docker compose file

```makefile
php_tests_phpunit: DKR_COMPOSE_FILE = -f ./docker-compose.yaml -f ./docker-compose.phpunit.yaml
php_tests_behat: DKR_COMPOSE_FILE = -f ./docker-compose.yaml -f ./docker-compose.behat.yaml
```

## commands

### composer install

```shell
make php_composer_install
```

```shell
PACKAGE=psr/log make php_composer_install
```

### composer update

```shell
make php_composer_update
```

```shell
PACKAGE=psr/log make php_composer_update
```

### tests

```shell
make php_tests_phpunit
```

```shell
make php_tests_behat
```

### tests against a worktree

Run the suite against a git [worktree's](https://git-scm.com/docs/git-worktree) code while
reusing the already-running local stack (image, compose files, secrets, services), with a
per-worktree database so parallel worktree runs never collide with each other or the main
checkout.

This needs **no changes in the consuming repo**. Bring the main stack up as usual and run
this from the MAIN checkout, pointing at a worktree — decrypted env/secret files (which are
gitignored and absent in a worktree) are still sourced from the main stack:

```shell
make dkr_up_local                                   # once: the stack it reuses must be up
make php_tests_worktree WORKTREE=/path/to/worktree
```

Pick a suite, or run an arbitrary command, with `TESTS` / `COMMAND`:

```shell
make php_tests_worktree WORKTREE=/path/to/worktree TESTS=behat
make php_tests_worktree WORKTREE=/path/to/worktree COMMAND="php artisan test"
```

How it works:

* **stack reuse** — it finds the running `cli` container for the compose project and reuses
  the exact compose files, image and services that created it (so it never rebuilds a stale
  image, and secrets come from the main stack's `env_file`). Bring the stack up first.
* **source** — only the code bind-mount is redirected to the worktree, via an auto-generated
  ephemeral compose override — your compose files are not edited. The app directory
  (the one holding `composer.json`) is auto-detected from the running mount; override with
  `APP_DIR=<path relative to the repo root>` if detection can't find it.
* **database isolation** — the run gets a unique, sanitised `DB_DATABASE` derived from the
  worktree path (override with `DB_DATABASE=...`), reusing the shared MySQL server. The
  database is created, granted to the app user, and **migrated** before the suite runs.
  Add `DB_SEED=1` for suites whose feature tests need seeded reference data, or `DB_FRESH=1`
  to drop and rebuild it for a clean slate.
* **composer drift** — if the worktree's `composer.lock` differs from the main checkout's
  (or its `vendor/` is missing) dependencies are installed into the worktree first;
  otherwise the worktree's `vendor/` is reused, so re-runs are fast.
