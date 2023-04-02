#!/usr/bin/env ash

# Installing PHP Extensions
docker-php-ext-configure opcache --enable-opcache &&
  docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp &&
  docker-php-ext-configure zip &&
  docker-php-ext-install -j "$(nproc)" \
    mysqli \
    pdo_mysql \
    sockets \
    bz2 \
    bcmath \
    exif

# note: for some reason if we build gd,intl with the rest of the extensions it will trow an error in php -v
docker-php-ext-install -j "$(nproc)" gd
docker-php-ext-install -j "$(nproc)" pcntl
install-php-extensions redis
install-php-extensions intl

# Enable production environment
mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
