# php

php_composer_%: CONTAINER ?= cli
php_composer_%: DKR_COMPOSE_ADDITIONAL_RUN = --no-deps

php_composer_install: COMMAND = composer install $(PACKAGE)
php_composer_install:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }

php_composer_update: COMMAND = composer update $(PACKAGE)
php_composer_update:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }

php_tests_%:
	$(DKR_COMPOSE_CMD_UP) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }

php_cmd_%: CONTAINER = cli
php_cmd_%:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
