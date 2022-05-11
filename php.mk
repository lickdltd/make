# php

php_composer_%: CONTAINER = cli
php_composer_%: DKR_COMPOSE_ADDITIONAL_RUN = --no-deps

php_composer_install: DKR_COMPOSE_PROJECT = $(NAME)-php-composer-install
php_composer_install: COMMAND = composer install $(PACKAGE)
php_composer_install:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)

php_composer_update: DKR_COMPOSE_PROJECT = $(NAME)-php-composer-update
php_composer_update: COMMAND = composer update $(PACKAGE)
php_composer_update:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)

php_tests_%: DKR_COMPOSE_PROJECT = $(NAME)-php-tests-$*
php_tests_%:
	$(DKR_COMPOSE_CMD_UP) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)

php_cmd_%: CONTAINER = cli
php_cmd_%: DKR_COMPOSE_PROJECT = $(NAME)-php-cmd-$*
php_cmd_%:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)
