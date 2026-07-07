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

Run the suite against a git worktree's code while reusing the already-running local
services (MySQL / Redis / Elasticsearch), with per-worktree database isolation so
parallel worktree runs don't collide with each other or the main checkout:

```shell
make php_tests_worktree WORKTREE=/path/to/worktree
```

Pick a suite, or run an arbitrary command, with `TESTS` / `COMMAND`:

```shell
make php_tests_worktree WORKTREE=/path/to/worktree TESTS=behat
make php_tests_worktree WORKTREE=/path/to/worktree COMMAND="php artisan test"
```

How it works:

* **source** — the worktree is bind-mounted via `DKR_COMPOSE_SRC` (see
  [docker.md](./docker.md#source-path)) rather than the main checkout.
* **services** — the container runs with `--no-deps`, reusing the services you already
  have `up` instead of starting a duplicate stack, so bring the main stack up first.
* **database isolation** — the run is given a unique, sanitised `DB_DATABASE` derived from
  the worktree path (override with `DB_DATABASE=...`). The shared MySQL server is reused;
  only the schema differs. Ensure your test bootstrap creates and migrates it (e.g.
  Laravel's `RefreshDatabase`).
* **composer drift** — if the worktree's `composer.lock` differs from the main
  checkout's (or its `vendor/` is missing) dependencies are installed for the worktree
  first, otherwise the existing `vendor/` is reused.

This requires your compose file to reference `${DKR_COMPOSE_SRC}` for the code volume and
to avoid a hardcoded `container_name` — see [docker.md](./docker.md#source-path).
