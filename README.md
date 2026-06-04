# Docker Build Tools CI

[![docker pull quay.io/pantheon-public/build-tools-ci](https://img.shields.io/badge/image-quay-blue.svg)](https://quay.io/repository/pantheon-public/build-tools-ci)
[![Deprecated](https://img.shields.io/badge/Pantheon-Deprecated-red?logo=pantheon)](https://pantheon.io/docs/oss-support-levels)

[![Docker Hub pantheonpublic/build-tools-ci](https://img.shields.io/docker/pulls/pantheonpublic/build-tools-ci)](https://hub.docker.com/repository/docker/pantheonpublic/build-tools-ci)

> **This project is deprecated.** This is the final release and will no longer receive updates, bug fixes, or security patches. If you are currently using this image, please migrate to an alternative solution.

This is the source Dockerfile for the [pantheon-public/build-tools-ci](https://quay.io/repository/pantheon-public/build-tools-ci) and [pantheonpublic/build-tools-ci](https://hub.docker.com/repository/docker/pantheonpublic/build-tools-ci) docker image.

## Image Contents

- [CircleCI PHP 7.3, Node, Headless browser Docker base image](https://hub.docker.com/r/circleci/php)
- [Terminus](https://github.com/pantheon-systems/terminus)
- Terminus plugins
  - [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin)
  - [Terminus Secrets Manager Plugin](https://github.com/pantheon-systems/terminus-secrets-manager-plugin)
  - [Terminus Rsync Plugin](https://github.com/pantheon-systems/terminus-rsync-plugin)
  - [Terminus Composer Plugin](https://github.com/pantheon-systems/terminus-composer-plugin)
  - [Terminus Mass Update Plugin](https://github.com/pantheon-systems/terminus-mass-update)
  - [Terminus Site Clone Plugin](https://github.com/pantheon-systems/terminus-site-clone-plugin)
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

- 9.x: Terminus 4. Produces:
  - 9.x-php8.2
  - 9.x-php8.3
  - 9.x-php8.4
- 8.x: Terminus 3. Produces:
  - 8.x-php7.4
  - 8.x-php8.0
  - 8.x-php8.1
  - 8.x-php8.2
  - 8.x-php8.3

Branches 7.x and lower are deprecated and unsupported.

## 9.x Docker images

### Building the image

From project root:

```
# PHPVERSION could be 8.2, 8.3 or 8.4.
PHPVERSION=8.4
docker build --build-arg PHPVERSION=$PHPVERSION -t quay.io/pantheon-public/build-tools-ci:9.x-php${PHPVERSION} .
```

### Using the image

#### Image name and tag

- quay.io/pantheon-public/build-tools-ci:9.x-php8.2
- quay.io/pantheon-public/build-tools-ci:9.x-php8.3
- quay.io/pantheon-public/build-tools-ci:9.x-php8.4

#### Usage example

Set the right image tag in the following files and it will work as expected:

- [Drupal 8 Github Actions](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/.ci/.github/workflows/build_deploy_and_test.yml)
- [Drupal 8 CircleCI](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/.circleci/config.yml)
- [Drupal 8 GitlabCI](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/.gitlab-ci.yml)
- [Drupal 8 Bitbucket Pipelines](https://github.com/pantheon-systems/example-drops-8-composer/blob/master/bitbucket-pipelines.yml)
