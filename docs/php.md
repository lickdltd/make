# php

> This also requires you to have [docker.mk](../docker.mk) installed.

* [setup](#setup)
    * [docker compose file](#docker-compose-file)
* [commands](#commands)
    * [composer install](#composer-install)
    * [composer update](#composer-update)
    * [tests](#tests)

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
