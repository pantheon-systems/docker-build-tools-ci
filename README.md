# Docker Build Tools CI

[![docker pull quay.io/pantheon-public/build-tools-ci](https://img.shields.io/badge/image-quay-blue.svg)](https://quay.io/repository/pantheon-public/build-tools-ci)


[![Docker Hub pantheonpublic/build-tools-ci](https://img.shields.io/docker/pulls/pantheonpublic/build-tools-ci)](https://hub.docker.com/repository/docker/pantheonpublic/build-tools-ci)

This is the source Dockerfile for the [pantheon-public/build-tools-ci](https://quay.io/repository/pantheon-public/build-tools-ci) and [pantheonpublic/build-tools-ci](https://hub.docker.com/repository/docker/pantheonpublic/build-tools-ci) docker image.

## Image Contents

- [CircleCI PHP 7.3, Node, Headless browser Docker base image](https://hub.docker.com/r/circleci/php)
- [Terminus](https://github.com/pantheon-systems/terminus)
- Terminus plugins
  - [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin)
  - [Terminus Secrets Plugin](https://github.com/pantheon-systems/terminus-secrets-plugin)
  - [Terminus Rsync Plugin](https://github.com/pantheon-systems/terminus-rsync-plugin)
  - [Terminus Quicksilver Plugin](https://github.com/pantheon-systems/terminus-quicksilver-plugin)
  - [Terminus Composer Plugin](https://github.com/pantheon-systems/terminus-composer-plugin)
  - [Terminus Drupal Console Plugin](https://github.com/pantheon-systems/terminus-drupal-console-plugin)
  - [Terminus Mass Update Plugin](https://github.com/pantheon-systems/terminus-mass-update)
  - [Terminus Aliases Plugin](https://github.com/pantheon-systems/terminus-aliases-plugin)
  - [Terminus CLU Plugin](https://github.com/pantheon-systems/terminus-clu-plugin)
- Test tools
  - headless chrome
  - phpunit
  - bats
  - behat
  - php_codesniffer
  - hub
  - lab
- Test scripts

## Branches

- 8.x: Use a CircleCI base image with Node JS, composer 2 and Terminus 3. Produces 7.x-php7.4 and 7.x-php8.0 image tags.
- 7.x: Use a CircleCI base image with Node JS and composer 2. Produces 7.x-php7.3, 7.x-php7.4 and 7.x-php8.0 image tags.
- 6.x: Use a CircleCI base image with Node JS
- 5.x: Don't create multidevs when commits are made to the default branch, instead working directly on the dev environment
- 4.x: Terminus 2.x and Build Tools 2.x
- 3.x: Deprecated: Terminus 1 with Build Tools 2.0.0-beta2
- 2.x: Terminus 1.x and Build Tools 1.x
- 1.x: Deprecated

## 8.x Docker images

### Building the image

From project root:

```
# PHPVERSION could be 7.4 or 8.0.
PHPVERSION=7.4
docker build --build-arg PHPVERSION=$PHPVERSION -t quay.io/pantheon-public/build-tools-ci:8.x-php${PHPVERSION} .
```

## 7.x Docker images

### Building the image

From project root:

```
# PHPVERSION could be 7.3, 7.4 or 8.0.
PHPVERSION=7.4
docker build --build-arg PHPVERSION=$PHPVERSION -t quay.io/pantheon-public/build-tools-ci:7.x-php${PHPVERSION} .
```

### Using the image

#### Image name and tag

- quay.io/pantheon-public/build-tools-ci:7.x-php7.4
- quay.io/pantheon-public/build-tools-ci:7.x-php8.0

#### Usage example

Set the right image tag in the following files and it will work as expected:

- [Drupal 8 Github Actions](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/.ci/.github/workflows/build_deploy_and_test.yml)
- [Drupal 8 CircleCI](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/.circleci/config.yml)
- [Drupal 8 GitlabCI](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/.gitlab-ci.yml)
- [Drupal 8 Bitbucket Pipelines](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/bitbucket-pipelines.yml)