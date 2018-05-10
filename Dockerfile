# Use an CircleCI-maintained PHP + node runtime as a parent image
# Was: drupaldocker/php:7.1-cli
FROM circleci/php:7.1-cli-node-browsers

# Lazy: go back to using 'root' user as drupaldocker/php:7.1-cli does.
USER root

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Install php extensions et. al. needed to run Drupal, just in case.
# c.f. https://github.com/drupal-docker/php
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libpq-dev libxml2-dev sudo git mysql-client openssh-client rsync \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring pdo_mysql pdo_pgsql zip \
  && docker-php-ext-install opcache bcmath soap \
  && pecl install redis-3.1.1 \
  && docker-php-ext-enable redis

# Collect the components we need for this image
RUN composer -n global require -n "hirak/prestissimo:^0.3"
RUN mkdir -p /usr/local/share/terminus
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/terminus require pantheon-systems/terminus "^1.7.1"
RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^8"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

env TERMINUS_PLUGINS_DIR /usr/local/share/terminus-plugins
RUN mkdir -p /usr/local/share/terminus-plugins
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-build-tools-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-secrets-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-rsync-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-quicksilver-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-composer-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-drupal-console-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-mass-update:^1
