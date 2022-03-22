# docker

DKR_COMPOSE_FILE ?= -f $(PWD)/docker-compose.yaml

DKR_COMPOSE_CMD = docker-compose $(DKR_COMPOSE_FILE)

DKR_COMPOSE_CMD_PULL = $(DKR_COMPOSE_CMD) pull $(DKR_COMPOSE_ADDITIONAL) --ignore-pull-failures
DKR_COMPOSE_CMD_BUILD = $(DKR_COMPOSE_CMD) build --force-rm --pull $(DKR_COMPOSE_ADDITIONAL)
DKR_COMPOSE_CMD_RUN = $(DKR_COMPOSE_CMD) run --rm $(DKR_COMPOSE_ADDITIONAL) $(CONTAINER) $(COMMAND)
DKR_COMPOSE_CMD_UP = $(DKR_COMPOSE_CMD) up --abort-on-container-exit --remove-orphans $(DKR_COMPOSE_ADDITIONAL)
DKR_COMPOSE_CMD_DOWN = $(DKR_COMPOSE_CMD) down --remove-orphans --volumes $(DKR_COMPOSE_ADDITIONAL)
DKR_COMPOSE_CMD_PUSH = $(DKR_COMPOSE_CMD) push $(DKR_COMPOSE_ADDITIONAL)

dkr_pull dkr_pull_%:
	$(DKR_COMPOSE_CMD_PULL)

dkr_build dkr_build_%:
	$(DKR_COMPOSE_CMD_BUILD)

dkr_run dkr_run_%:
	$(DKR_COMPOSE_CMD_RUN)

dkr_up dkr_up_%:
	$(DKR_COMPOSE_CMD_UP)

dkr_down dkr_down_%:
	$(DKR_COMPOSE_CMD_DOWN)

dkr_push dkr_push_%:
	$(DKR_COMPOSE_CMD_PUSH)
