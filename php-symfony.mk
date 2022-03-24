# php-symfony

php_symfony_%: CONTAINER = cli

php_symfony_migrate: COMMAND = php bin/console doctrine:migrations:migrate
php_symfony_migrate: dkr_run
