# php-symfony

php_symfony_%: CONTAINER = cli

php_symfony_migrate: DKR_COMPOSE_PROJECT = $(NAME)-php-symfony-migrate
php_symfony_migrate: COMMAND = php bin/console doctrine:migrations:migrate
php_symfony_migrate: dkr_run dkr_down
