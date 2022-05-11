# php-symfony

php_symfony_%: CONTAINER = cli

php_symfony_migrate: DKR_COMPOSE_PROJECT = $(NAME)-php-symfony-migrate
php_symfony_migrate: COMMAND = php bin/console doctrine:migrations:migrate
php_symfony_migrate:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)
