ARG PHP_VERSION=8.0.1
FROM php:${PHP_VERSION}-alpine
LABEL maintainer="Pezhvak <pezhvak@imvx.org>"
# NOTE: ARGs before FROM cannot be accessed during build time (https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)
ARG COMPOSER_VERSION=2

# Copy PHP Extension Installer (https://github.com/mlocati/docker-php-extension-installer)
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Copy Scripts
COPY scripts /tmp
RUN chmod +x /tmp/*.sh

# Install
RUN ash /tmp/install-packages.sh
RUN ash /tmp/install-php.sh
RUN ash /tmp/install-node-yarn.sh

# Cleanup
RUN ash /tmp/cleanup.sh
RUN rm -rf /tmp/*
