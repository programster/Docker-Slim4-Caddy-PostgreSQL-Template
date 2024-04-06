FROM debian:12


ENV DEBIAN_FRONTEND=noninteract


RUN apt-get update && apt-get dist-upgrade -y


# Expose port 80/443 for the web requests
EXPOSE 80
EXPOSE 443


# Install the relevant packages
RUN apt-get update && apt-get install vim curl php-fpm git unzip supervisor cron composer \
    php8.2-cli php8.2-xml php8.2-mbstring php8.2-curl php8.2-bcmath  \
    php8.2-pgsql php8.2-zip php8.2-gd -y


# Install caddy webserver
RUN apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl -y \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
  && apt-get update \
  && apt-get install caddy -y


# increase security by configuring php-fpm to only execute exact matches for files,
# rather than executing the closest matching file.
ENV SEARCH=";cgi.fix_pathinfo=.*"
ENV REPLACE="cgi.fix_pathinfo=1"
ENV FILEPATH="/etc/php/8.2/fpm/php.ini"
RUN sed -i "s|$SEARCH|$REPLACE|" $FILEPATH


# Set display errors to on, we can decide in the application layer whether to hide or not based on the environment.
ENV SEARCH="display_errors = Off"
ENV REPLACE="display_errors = On"
ENV FILEPATH="/etc/php/8.2/fpm/php.ini"
RUN sed -i "s|$SEARCH|$REPLACE|" $FILEPATH


# Add the site's code to the container.
# When in development, use a volume to overwrite this area.
COPY --chown=root:www-data site /var/www/site


# Install PHP packages
RUN chmod 750 --recursive /var/www/site \
    && cd /var/www/site \
    && composer install \
    && chown --recursive root:www-data /var/www/site/vendor \
    && chmod 750 --recursive /var/www/site/vendor


# Add our Caddyfile configuration.
ADD docker/Caddyfile /etc/caddy/Caddyfile


# Replace the php-fpm pool config so that we listen on TCP port 9000 instead of using a local
# unix socket. Also set static number of processes which container will set according to CPU count on startup (see
# startup.sh)
# https://serverfault.com/questions/884468/nginx-with-php-fpm-resource-temporarily-unavailable-502-error/884477#884477
ADD docker/php-fpm-pool.conf /etc/php/8.2/fpm/pool.d/www.conf


# Use the crontab file.
# The crontab file was already added when we added "project"
ADD docker/crons.conf /root/crons.conf
RUN crontab /root/crons.conf && rm /root/crons.conf


# Copy the script across that will create the .env file on startup for the web user to use.
COPY docker/create-env-file.php /root/create-env-file.php


# Add the startup script to the container
COPY docker/startup.sh /root/startup.sh


# Change the workdir to /var/www/site so that when devs enter the container, they are at the site
WORKDIR /var/www/site


# Execute the containers startup script which will start many processes/services
# The startup file was already added when we added "project"
CMD ["/bin/bash", "/root/startup.sh"]
