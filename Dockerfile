FROM alpine:latest
LABEL maintainer="Juan Baez"

ARG CONFIGUREFLAGS="--prefix=/services --disable-nls"

ENV TARGET_RELEASE v7.2.10-r2

# Install the build dependencies
RUN apk add --no-cache build-base git musl openssl openssl-dev gnutls gnutls-dev

# Build atheme. Change submodule's libmowgli-2 branch to master.
RUN mkdir -p /services \
    && mkdir -p /tmp/src \
    && cd /tmp/src \
    && git clone https://github.com/atheme/atheme.git --branch ${TARGET_RELEASE} --single-branch \
    && cd atheme \
    && git config -f .gitmodules submodule.libmowgli-2.branch master \
    && git submodule update --init \
    && git submodule update --remote --recursive \
    && ./configure ${CONFIGUREFLAGS} \
    && make -j`getconf _NPROCESSORS_ONLN` \
    && make install \
    && cd / \
    && rm -rf /tmp/* \
    && addgroup -g 1000 -S atheme \
    && adduser -h /services -D -u 1000 -s /sbin/nologin -S -G atheme atheme \
    && chown -R atheme:atheme /services

USER atheme
VOLUME ["/services/etc" "/services/var"]
ENTRYPOINT ["/services/bin/atheme-services", "-p", "/services/atheme.pid", "-n"]
