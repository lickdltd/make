# docker

* [setup](#setup)
    * [variables](#variables)
    * [docker compose file](#docker-compose-file)
    * [source path](#source-path)
* [commands](#commands)
    * [dkr_pull](#dkr_pull)
    * [dkr_build](#dkr_build)
    * [dkr_run](#dkr_run)
    * [dkr_up](#dkr_up)
    * [dkr_down](#dkr_down)
    * [dkr_push](#dkr_push)

## setup

### variables

```makefile
export DOCKER_IMAGE_URL = $(AWS_ECR_DOMAIN)/$(NAME)
export DOCKER_TAG = $(GIT_TAG)
```

The variable `$(AWS_ECR_DOMAIN)` comes from [aws.mk](../aws.mk) and documented in [aws.md](./aws.md).
The variable `$(GIT_TAG)` comes from [common.mk](../common.mk) and documented in [common.md](./common.md).

### docker compose file

```makefile
dkr_build: DKR_COMPOSE_FILE = -f ./docker-compose.build.yaml
```

### source path

`DKR_COMPOSE_SRC` is the path to the source tree bind-mounted into the containers.
It defaults to `$(PWD)` (the main checkout) and is exported so `docker compose` can
interpolate it inside your compose file:

```yaml
services:
  cli:
    # no `container_name:` — lets an isolated run coexist with the main stack
    volumes:
      - ${DKR_COMPOSE_SRC:-.}:/app
```

Referencing `${DKR_COMPOSE_SRC}` instead of a hardcoded path, and omitting
`container_name`, is what lets [`php_tests_worktree`](./php.md#tests-against-a-worktree)
run a git worktree's code against the already-running main-checkout services without
conflicting with them.

## commands

### dkr_pull

```shell
make dkr_pull
```

### dkr_build

```shell
make dkr_build
```

### dkr_run:

```shell
make dkr_run
```

### dkr_up:

```shell
make dkr_up
```

### dkr_down:

```shell
make dkr_down
```

### dkr_push:

```shell
make dkr_push
```
