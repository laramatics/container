ARG PHP_VERSION=8.0.1
FROM php:${PHP_VERSION}-alpine
LABEL maintainer="Pezhvak <pezhvak@imvx.org>"
# NOTE: ARGs before FROM cannot be accessed during build time (https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)
ARG COMPOSER_VERSION=2
ARG USER_ID=1235
ARG GROUP_ID=1235
ENV USER_ID=${USER_ID}
ENV GROUP_ID=${GROUP_ID}

# Setting up
WORKDIR /var/www/html
RUN addgroup -g ${GROUP_ID} deployer
RUN adduser -DHS -u ${USER_ID} -G deployer -G wheel deployer
echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel

# Copy PHP Extension Installer (https://github.com/mlocati/docker-php-extension-installer)
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Copy Scripts
COPY scripts /tmp
RUN chmod +x /tmp/*.sh
COPY scripts/start-container /usr/local/bin
RUN chmod +x /usr/local/bin/start-container

# Install
RUN ash /tmp/install-packages.sh
RUN ash /tmp/install-php.sh

# Cleanup
RUN ash /tmp/cleanup.sh
RUN rm -rf /tmp/*

# Serving
EXPOSE 80
ENTRYPOINT ["start-container"]