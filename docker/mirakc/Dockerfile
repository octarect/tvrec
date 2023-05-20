FROM mirakc/mirakc:2.1.0-alpine

# Dependencies for building arib-b25-stream-test
ARG BUILD_DEPS="build-base pkgconfig pcsc-lite-dev"
# pcsc-lite includes command `pcscd`
RUN set -x \
 && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
 && apk add --no-cache pcsc-lite pcsc-tools ccid \
 && apk add nodejs npm \
 && npm install -g --unsafe arib-b25-stream-test \
 && apk del .build-deps

ENTRYPOINT pcscd && mirakc
