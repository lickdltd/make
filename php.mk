# php

php_composer_%: CONTAINER = cli
php_composer_%: DKR_COMPOSE_ADDITIONAL = --no-deps

php_composer_install: COMMAND = composer install $(PACKAGE)
php_composer_install: dkr_run dkr_down

php_composer_update: COMMAND = composer update $(PACKAGE)
php_composer_update: dkr_run dkr_down

php_tests_%:
	$(DKR_COMPOSE_CMD_UP)
	$(DKR_COMPOSE_CMD_DOWN)
