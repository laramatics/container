<div align="center">

# Laravel App Container

![GitHub](https://img.shields.io/github/license/laramatics/container)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/laramatics/container/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/laramatics/container)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/laramatics/container)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/laramatics/container)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/laramatics/container)

</div>

## About

This repository contains a `Dockerfile` which builds an [image](https://hub.docker.com/r/laramatics/container)
for serving your Laravel app.

### Table of Contents

- [Usage](#usage)
- [Folder Structure](#folder-structure)
- [Packages and Services](#packages-and-services)
    - [Customizing build versions](#customizing-build-versions)
    - [Adding more PHP extensions](#adding-more-php-extensions)
    - [Adding more packages](#adding-more-packages)
    - [Testing](#testing)

## Usage

Using the image is straight-forward and easy to use, create a `Dockerfile` in your app and copy your files into the
container, do whatever is necessary:

```dockerfile
FROM laramatics/container:latest

# (optional) copy your own configurations to the container
COPY /docker/config/php.ini "$PHP_INI_DIR/conf.d/laramatics-container.ini"

# (optional) override default nginx configuration file
COPY /docker/config/your_nginx_cnf.conf /etc/nginx/http.d/default.conf

# (optional) add a supervisor configuration file for your workers
COPY /docker/config/myapp.conf /etc/supervisor.conf/myapp.conf

# (optional) if you want it to run on all start scripts then add it here
COPY /docker/config/myapp.conf /etc/supervisor.d/myapp.conf

# copy app to the container
COPY ./ /var/www/html
```

Once your files are added to the container, you will have to build an image from your `Dockerfile`:

```bash
docker build -t <image_name> .
```

All done! run your container and enjoy!

## Folder Structure

Although folder structure is self-explanatory, description is below:

```
.
├── configs
│   ├── crontab.txt           # crontab configuration file.
│   ├── nginx.conf            # default nginx configuration file.
│   └── supervisord.conf      # php/nginx supervisor configuration file.
├── Dockerfile
├── LICENSE
├── readme.md
├── scripts
│   ├── cleanup.sh            # Removes build dependencies for lighter image size.
│   ├── install-packages.sh   # OS packages will be installed by this file.
│   ├── install-php.sh        # PHP extensions and installation.
│   └── start-container       # Container entry-point script.
│   └── start-cron            # Running container with cron job role.
│   └── start-worker          # Running container with artisan worker role.
│   └── start-supervisor      # Running container with supervisor role.
└── tests
    └── goss.yaml             # See "testing" section.
```

## Packages and Services

We created the `Dockerfile` with image size in mind, so only packages and PHP extensions which are absolutely necessary
are installed.

|Service| Version |Argument|
|---|:-------:|:---:|
|PHP|  8.2.1  |`PHP_VERSION`|
|nginx| latest  |`N/A`|
|supervisor| latest  |`N/A`|

### Customizing build versions

As you can see in the table above, some services have an argument in `Dockerfile` for you to modify the installation
version. To do so, you need to clone the repo and build the image yourself:

```bash
git clone https://github.com/laramatics/container.git
cd app
# Modify files...
docker build \
  --build-arg PHP_VERSION=8.2.1 \
  -t <image_name> .
```

### Adding more PHP extensions

If you want to add more extensions to the PHP installation, you will have to build your own image based on the one
already built or modify the `Dockerfile` and `scripts/*` to your liking and build your own image from that as
described [here](#adding-more-packages).

See [Docker PHP Extension Installer](https://github.com/mlocati/docker-php-extension-installer)
for available extensions, however you can also install them from the source.

```dockerfile
FROM laramatics/container:latest
# add your extentions here...
RUN docker-php-ext-install -j "$(nproc)" <package_name>
```

### Adding more packages

Sometimes you need a specific package for your pipeline; as described in the previous section, you can build your own
image from `laramatics/container` or clone this repo and modify files to suit your needs.

```shell
git clone https://github.com/laramatics/container.git
cd app
# Modify files...
docker build -t <image_name> .
```

### Testing

Tests are written using [GOSS](https://github.com/aelsabbahy/goss/tree/master/extras/dcgoss), to test your changes after
modifying source files and building your own image, run:

```shell
GOSS_FILES_PATH=tests dgoss run -it <image_name> /bin/ash -l
```

### FAQ

*Q:* How can i change php-fpm port?

*A:* Sometimes you need to change default php-fpm port which is 9000 in order to serve multiple containers under same
pod. to do that modify the port in `/usr/local/etc/php-fpm.d/zz-docker.conf`.
