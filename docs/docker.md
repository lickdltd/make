# docker

* [setup](#setup)
    * [variables](#variables)
    * [docker compose file](#docker-compose-file)
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
export DOCKER_IMAGE_URL = 843827012977.dkr.ecr.eu-west-1.amazonaws.com/$(NAME)
export DOCKER_TAG = $(GIT_TAG)
```

The variable `$(GIT_TAG)` comes from [common.mk](../common.mk) and documented in [common.md](./common.md).

### docker compose file

```makefile
dkr_build: DKR_COMPOSE_FILE = -f ./docker-compose.build.yaml
```

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
