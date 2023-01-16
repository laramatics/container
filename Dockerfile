ARG PHP_VERSION=8.2.1
FROM php:${PHP_VERSION}-fpm-alpine
LABEL maintainer="Pezhvak <pezhvak@imvx.org>"
# NOTE: ARGs before FROM cannot be accessed during build time (https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)

WORKDIR /var/www/html

# Copy PHP Extension Installer (https://github.com/mlocati/docker-php-extension-installer)
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Copy Scripts
COPY scripts /tmp
RUN chmod +x /tmp/*.sh
COPY scripts/start-container /usr/bin
COPY scripts/start-cron /usr/bin
COPY scripts/start-worker /usr/bin
RUN chmod +x /usr/bin/start-container
RUN chmod +x /usr/bin/start-cron
RUN chmod +x /usr/bin/start-worker

# Install
RUN ash /tmp/install-packages.sh
RUN ash /tmp/install-php.sh

# Setting up Supervisor
RUN sed -i "s/*.ini/*.conf/" /etc/supervisord.conf
RUN sed -i "s/;pidfile=/pidfile=/" /etc/supervisord.conf
RUN mkdir /etc/supervisor.d/

# Cleanup
RUN ash /tmp/cleanup.sh
RUN rm -rf /tmp/*

# Serving
EXPOSE 80

# Services supervisor config
COPY ./configs/supervisord.conf /etc/supervisor.d/php-nginx.conf

# Override nginx's default config
COPY ./configs/nginx.conf /etc/nginx/http.d/default.conf

# Set crontab configurations
COPY ./configs/crontab.txt /etc/crontabs/root

CMD ["/usr/bin/supervisord", "-n","-c", "/etc/supervisord.conf"]
ENTRYPOINT ["start-container"]
