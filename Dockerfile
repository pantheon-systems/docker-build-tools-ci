# Use an official Python runtime as a parent image
FROM drupaldocker/php:7.1-cli

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Collect the components we need for this image
RUN apt-get update
RUN composer -n global require -n "hirak/prestissimo:^0.3"
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share require pantheon-systems/terminus "^1"
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share require drush/drush "^8"
RUN mkdir -p /usr/local/share/terminus-plugins
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-build-tools-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-secrets-plugin:^1
