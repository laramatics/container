<div align="center">

# Laravel App Container

![GitHub](https://img.shields.io/github/license/laramatics/app)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/laramatics/app/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/laramatics/app)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/laramatics/app)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/laramatics/app)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/laramatics/app)

</div>

## About

This repository contains a `Dockerfile` which builds an [image](https://hub.docker.com/r/laramatics/app)
for serving your Laravel app.

### Table of Contents

- [Usage](#usage)
- [Folder Structure](#folder-structure)
- [Packages and Services](#packages-and-services)
  - [Customizing build versions](#customizing-build-versions)
  - [Adding more PHP extensions](#adding-more-php-extensions)
  - [Adding more packages](#adding-more-packages)
  - [Testing](#testing)
- [References](#references)

## Usage

Using the image is straight-forward and easy to use, create a `Dockerfile` in your app and copy your files into the
container, do whatever is necessary:

```dockerfile
FROM laramatics/app:latest

# (optional) copy your own configurations to the container
COPY /docker/config/php.ini "$PHP_INI_DIR/conf.d/laramatics-app.ini"

# copy app to the container
COPY ./ /var/www/html
RUN chown -R $USER_ID:$USER_GROUP /var/www/html
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
├── Dockerfile
├── LICENSE
├── readme.md
├── scripts
│   ├── cleanup.sh            # Removes build dependencies for lighter image size.
│   ├── install-packages.sh   # OS packages will be installed by this file.
│   ├── install-php.sh        # PHP extensions and installation.
│   └── start-container       # Container entry-point script
└── tests
    └── goss.yaml             # See "testing" section
```

## Packages and Services

We created the `Dockerfile` with image size in mind, so only packages and PHP extensions which are absolutely necessary
are installed.

|Service|Version|Argument|
|---|:---:|:---:|
|PHP|8.0.1|`PHP_VERSION`|
|Composer|2.0.9|`COMPOSER_VERSION`|

### Customizing build versions

As you can see in the table above, some services have an argument in `Dockerfile` for you to modify the installation version.
To do so, you need to clone the repo and build the image yourself:

```bash
git clone https://github.com/laramatics/app.git
cd app
# Modify files...
docker build \
  --build-args USER_ID=1235
  --build-args GROUP_ID=1235
  --build-arg PHP_VERSION=8.0.1 \
  --build-arg COMPOSER_VERSION=2 \
  -t <image_name> .
```

***Note:*** By default `deployer` user inside the container will use `uid` and `gid` of `1235`, you can change that to
match your own setup, the username doesn't matter, once you bind `/var/www/html` to your docker host, the only thing
that matters is `uid` and `gid` of the files (that's how linux works).

### Adding more PHP extensions

If you want to add more extensions to the PHP installation, you will have to build your own image based on the one
already built or modify the `Dockerfile` and `scripts/*` to your liking and build your own image from that as
described [here](#adding-more-packages).

See [Docker PHP Extension Installer](https://github.com/mlocati/docker-php-extension-installer)
for available extensions, however you can also install them from the source.

```dockerfile
FROM laramatics/app:latest
# add your extentions here...
RUN docker-php-ext-install -j "$(nproc)" <package_name>
```

### Adding more packages

Sometimes you need a specific package for your pipeline; as described in the previous section, you can build your own
image from `laramatics/app` or clone this repo and modify files to suit your needs.

```shell
git clone https://github.com/laramatics/app.git
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

# References

- [Useful gist](https://gist.github.com/avishayp/33fcee06ee440524d21600e2e817b6b7)