# node

node_npm_%: CONTAINER = node
node_npm_%: DKR_COMPOSE_ADDITIONAL_RUN = --no-deps

node_npm_install: COMMAND = npm install $(PACKAGE)
node_npm_install: dkr_run dkr_down

node_npm_update: COMMAND = npm update $(PACKAGE)
node_npm_update: dkr_run dkr_down

node_cmd_%: CONTAINER = node
node_cmd_%: DKR_COMPOSE_PROJECT = $(NAME)-$*
node_cmd_%:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)
