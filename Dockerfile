FROM drupaldocker/php:7.0-cli-2.x
MAINTAINER Eric Woods <ewoods@ithaca.edu>

WORKDIR /build-tools-ci
ADD . /build-tools-ci

### be fast...
RUN composer -n global require -n "hirak/prestissimo:^0.3"

### terminus
ENV TERMINUS_VERSION 1.8.1
ENV TERMINUS_DIR /usr/local/share/terminus
ENV TERMINUS_PLUGINS_DIR /usr/local/share/terminus-plugins

RUN mkdir -p $TERMINUS_DIR \
    && composer -n --working-dir=$TERMINUS_DIR require pantheon-systems/terminus:$TERMINUS_VERSION

RUN mkdir -p $TERMINUS_PLUGINS_DIR \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-build-tools-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-secrets-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-rsync-plugin:^1 \
	&& composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-quicksilver-plugin:^1 \
	&& composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-composer-plugin:^1 \
	&& composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-drupal-console-plugin:^1 \
	&& composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-mass-update:^1 \
	&& composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-site-clone-plugin:^1

### npm for linting tools
RUN apk upgrade --update --no-cache && apk add --update \
    bash \
    nodejs \
    nodejs-npm

### linting tools
## (revisions based on npm info "eslint-config-airbnb@latest" peerDependencies)
RUN npm install --global eslint@^4.19.1 \
    && npm install --global eslint-plugin-import@^2.12.0 \
    && npm install --global eslint-plugin-jsx-a11y@^6.0.3 \
    && npm install --global eslint-plugin-react@^7.9.1 \
    && npm install --global eslint-config-airbnb@^17.0.0 \
    && npm cache clean --force
