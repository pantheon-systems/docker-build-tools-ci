# Docker PHP CI

[![docker pull quay.io/joel_travieso/ic-circleci-docker](https://img.shields.io/badge/image-quay-blue.svg)](https://quay.io/repository/joel_travieso/ic-circleci-docker)

This is the source Dockerfile for the [joel_travieso/ic-circleci-docker](https://quay.io/repository/joel_travieso/ic-circleci-docker) docker image, based on [pantheon-public/build-tools-ci](https://quay.io/repository/pantheon-public/build-tools-ci).

## Image Contents

- [Drupal PHP 7.1 Docker base image](https://github.com/drupal-docker/php/tree/master/7.1)
- [Terminus](https://github.com/pantheon-systems/terminus)
- Terminus plugins
  - [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin)
  - [Terminus Secrets Plugin](https://github.com/pantheon-systems/terminus-secrets-plugin)
  - [Terminus Rsync Plugin](https://github.com/pantheon-systems/terminus-rsync)
  - [Terminus Quicksilver Plugin](https://github.com/pantheon-systems/terminus-quicksilver-plugin)
  - [Terminus Composer Plugin](https://github.com/pantheon-systems/terminus-composer-plugin)
  - [Terminus Drupal Console Plugin](https://github.com/pantheon-systems/terminus-drupal-console-plugin)
  - [Terminus Mass Update Plugin](https://github.com/pantheon-systems/terminus-mass-update)
- Test scripts
- [Nodejs](http://nodejs.org/dist/v6.1.0/node-v6.1.0-linux-x64.tar.gz)
- NPM (latest)
- Gulp
- ESLint