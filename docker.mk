# docker

NAME ?= default

DKR_COMPOSE_FILE ?= -f $(PWD)/docker-compose.yaml
DKR_COMPOSE_PROJECT = $(NAME)

DKR_COMPOSE_CMD = COMPOSE_PROFILES=$(DKR_COMPOSE_PROFILES) docker-compose $(DKR_COMPOSE_FILE) -p $(DKR_COMPOSE_PROJECT)

DKR_COMPOSE_CMD_PULL = $(DKR_COMPOSE_CMD) pull $(DKR_COMPOSE_ADDITIONAL)$(DKR_COMPOSE_ADDITIONAL_PULL) --ignore-pull-failures
DKR_COMPOSE_CMD_BUILD = $(DKR_COMPOSE_CMD) build --force-rm --pull $(DKR_COMPOSE_ADDITIONAL)$(DKR_COMPOSE_ADDITIONAL_BUILD)
DKR_COMPOSE_CMD_RUN = $(DKR_COMPOSE_CMD) run --rm $(DKR_COMPOSE_ADDITIONAL)$(DKR_COMPOSE_ADDITIONAL_RUN) $(CONTAINER) $(COMMAND)
DKR_COMPOSE_CMD_UP = $(DKR_COMPOSE_CMD) up --abort-on-container-exit --remove-orphans $(DKR_COMPOSE_ADDITIONAL)$(DKR_COMPOSE_ADDITIONAL_UP)
DKR_COMPOSE_CMD_DOWN = $(DKR_COMPOSE_CMD) down --remove-orphans --volumes $(DKR_COMPOSE_ADDITIONAL)$(DKR_COMPOSE_ADDITIONAL_DOWN)
DKR_COMPOSE_CMD_PUSH = $(DKR_COMPOSE_CMD) push $(DKR_COMPOSE_ADDITIONAL)$(DKR_COMPOSE_ADDITIONAL_PUSH)

DKR_BUILDX_BAKE_CMD = docker buildx bake

dkr_pull dkr_pull_%:
	$(DKR_COMPOSE_CMD_PULL)

dkr_build dkr_build_%:
ifneq ($(shell docker buildx version),)
	$(DKR_BUILDX_BAKE_CMD)
else
	$(DKR_COMPOSE_CMD_BUILD)
endif

dkr_run dkr_run_%:
	$(DKR_COMPOSE_CMD_RUN)

dkr_up dkr_up_%:
	$(DKR_COMPOSE_CMD_UP)

dkr_down dkr_down_%:
	$(DKR_COMPOSE_CMD_DOWN)

dkr_push dkr_push_%:
	$(DKR_COMPOSE_CMD_PUSH)
