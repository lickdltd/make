# docker

DKR_COMPOSE_FILE ?= -f $(PWD)/docker-compose.yaml

DKR_COMPOSE_CMD = docker-compose $(DKR_COMPOSE_FILE)

dkr_pull:
	$(DKR_COMPOSE_CMD) pull

dkr_build:
	$(DKR_COMPOSE_CMD) build --force-rm --pull

dkr_run:
	$(DKR_COMPOSE_CMD) run --rm $(CONTAINER) $(COMMAND)

dkr_up:
	$(DKR_COMPOSE_CMD) up --abort-on-container-exit

dkr_down:
	$(DKR_COMPOSE_CMD) down --remove-orphans --volumes

dkr_push:
	$(DKR_COMPOSE_CMD) push
