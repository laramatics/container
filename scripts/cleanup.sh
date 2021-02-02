#!/usr/bin/env ash

# Remove Build Dependencies
apk del -f .build-deps
rm /usr/bin/install-php-extensions