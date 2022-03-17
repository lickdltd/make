# docker

DKR_COMPOSE_FILE ?= -f $(PWD)/docker-compose.yaml

DKR_COMPOSE_CMD = docker-compose $(DKR_COMPOSE_FILE)

DKR_COMPOSE_CMD_PULL = $(DKR_COMPOSE_CMD) pull
DKR_COMPOSE_CMD_BUILD = $(DKR_COMPOSE_CMD) build --force-rm --pull
DKR_COMPOSE_CMD_RUN = $(DKR_COMPOSE_CMD) run --rm $(CONTAINER) $(COMMAND)
DKR_COMPOSE_CMD_UP = $(DKR_COMPOSE_CMD) up --abort-on-container-exit
DKR_COMPOSE_CMD_DOWN = $(DKR_COMPOSE_CMD) down --remove-orphans --volumes
DKR_COMPOSE_CMD_PUSH = $(DKR_COMPOSE_CMD) push

dkr_pull:
	$(DKR_COMPOSE_CMD_PULL)

dkr_build:
	$(DKR_COMPOSE_CMD_BUILD)

dkr_run:
	$(DKR_COMPOSE_CMD_RUN)

dkr_up:
	$(DKR_COMPOSE_CMD_UP)

dkr_down:
	$(DKR_COMPOSE_CMD_DOWN)

dkr_push:
	$(DKR_COMPOSE_CMD_PUSH)
