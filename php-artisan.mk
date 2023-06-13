# php-artisan

php_artisan_%: CONTAINER = cli

php_artisan_migrate: DKR_COMPOSE_PROJECT = $(NAME)-php-artisan-migrate
php_artisan_migrate: COMMAND = php artisan migrate
php_artisan_migrate:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
