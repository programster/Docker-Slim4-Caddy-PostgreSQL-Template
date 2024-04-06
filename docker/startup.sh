# Please do not manually call this file!
# This script is run by the docker container when it is "run"


# Create the .env file
php /root/create-env-file.php /.env


# Run migrations after waiting for the database to be available.
php /var/www/site/scripts/wait-for-database.php
php /var/www/site/scripts/migrate.php


# Start the PHP fastCGI process manager after performing a last second configuration of the number of processes to
# have it manage based on the number of cores.
NUM_PROCS=`cat /proc/cpuinfo | awk '/^processor/{print $3}'| wc -l`
SEARCH="pm.max_children = 4"
REPLACE="pm.max_children = $NUM_PROCS"
FILEPATH="/etc/php/8.2/fpm/pool.d/www.conf"
sed -i "s;$SEARCH;$REPLACE;" $FILEPATH
service php8.2-fpm start


# Start the cron service in the background
cron


# Run cron as the foreground process
/usr/bin/caddy run --config=/etc/caddy/Caddyfile
