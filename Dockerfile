ARG PHPVERSION

# Use an official Python runtime as a parent image
FROM circleci/php:${PHPVERSION}-node-browsers

# Switch to root user
USER root

# Install necessary packages for PHP extensions
RUN apt-get update && \
     apt-get install -y \
        dnsutils \
        libmagickwand-dev \
        libzip-dev \
        libsodium-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libicu-dev \
        libxml2-dev \
        g++ \
        git

# Add necessary PHP Extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

RUN pecl config-set php_ini /usr/local/etc/php/php.ini && \
        pear config-set php_ini /usr/local/etc/php/php.ini && \
        pecl channel-update pecl.php.net

ARG PHPVERSION
RUN if [ "$PHPVERSION" = "7.3" ]; then docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/; \
    else \
        docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/; fi \
    &&  docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure sodium
RUN docker-php-ext-install sodium
RUN pecl install libsodium

RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN docker-php-ext-install bcmath

RUN docker-php-ext-install soap

RUN pecl install pcov
RUN docker-php-ext-enable pcov

# Set the memory limit to unlimited for expensive Composer interactions
RUN echo "memory_limit=-1" > /usr/local/etc/php/conf.d/memory.ini

###########################
# Install build tools things
###########################

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Collect the components we need for this image
RUN apt-get update
RUN apt-get install -y ruby jq curl rsync hub
RUN gem install circle-cli

# Make sure we are on the latest version of Composer
RUN composer selfupdate --2

# Add lab in case anyone wants to automate GitLab MR creation, etc.
RUN curl -s https://raw.githubusercontent.com/zaquestion/lab/master/install.sh | bash

# Create an unpriviliged test user
RUN groupadd -g 999 tester && \
    useradd -r -m -u 999 -g tester tester && \
    adduser tester sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R tester /usr/local && \
    chown -R tester /build-tools-ci
USER tester

# Install terminus
RUN curl -L https://github.com/pantheon-systems/terminus/releases/download/3.0.3/terminus.phar -o /usr/local/bin/terminus && \
    chmod +x /usr/local/bin/terminus
RUN terminus self:update

# Install CLU
RUN mkdir -p /usr/local/share/clu
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/clu require danielbachhuber/composer-lock-updater:^0.8.2

# Install Drush
RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^10"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

# Add a collection of useful Terminus plugins
RUN terminus self:plugin:add terminus-build-tools-plugin
RUN terminus self:plugin:add terminus-clu-plugin
RUN terminus self:plugin:add terminus-secrets-plugin
RUN terminus self:plugin:add terminus-rsync-plugin
RUN terminus self:plugin:add terminus-quicksilver-plugin
RUN terminus self:plugin:add terminus-composer-plugin
RUN terminus self:plugin:add terminus-drupal-console-plugin
RUN terminus self:plugin:add terminus-mass-update
RUN terminus self:plugin:add terminus-site-clone-plugin

ENV TERMINUS_PLUGINS_DIR=/home/tester/.terminus/plugins-3.x
ENV TERMINUS_DEPENDENCIES_BASE_DIR=/home/tester/.terminus/terminus-dependencies

# Add phpcs for use in checking code style
RUN mkdir ~/phpcs && cd ~/phpcs && COMPOSER_BIN_DIR=/usr/local/bin composer require squizlabs/php_codesniffer:^2.7

# Add phpunit for unit testing
RUN mkdir ~/phpunit && cd ~/phpunit && COMPOSER_BIN_DIR=/usr/local/bin composer require phpunit/phpunit

# Add bats for functional testing
RUN git clone https://github.com/sstephenson/bats.git; bats/install.sh /usr/local

# Add Behat for more functional testing
RUN mkdir ~/behat && \
    cd ~/behat && \
    COMPOSER_BIN_DIR=/usr/local/bin \
    composer require \
        "behat/behat:^3.5" \
        "behat/mink:*" \
        "behat/mink-extension:^2.2" \
        "behat/mink-goutte-driver:^1.2" \
        "drupal/drupal-extension:*"
