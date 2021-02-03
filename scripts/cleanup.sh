#!/usr/bin/env ash

# Remove Build Dependencies
apk del -f .build-deps
rm /usr/local/bin/install-php-extensions
rm /usr/local/bin/docker-php-*
