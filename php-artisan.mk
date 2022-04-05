# php-artisan

php_artisan_%: CONTAINER = cli

php_artisan_migrate: COMMAND = php artisan migrate
php_artisan_migrate: dkr_run dkr_down
