#
#  Dockerfile
#  Vaporizer
#
#  Installs Swift stack on Ubuntu and sets compiled binary as start command

FROM ubuntu:14.04

MAINTAINER Christopher Reitz <christopher@reitz.re>
ENV APP_NAME Vaporizer

# HTTP Port
EXPOSE 8080

# Swift Version
ENV SWIFT_PLATFORM ubuntu14.04
ENV SWIFT_VERSION 3.0

ENV SWIFT_BRANCH swift-$SWIFT_VERSION-release
ENV SWIFT_RELEASE swift-$SWIFT_VERSION-RELEASE
ENV SWIFT_ARCHIVE_NAME $SWIFT_RELEASE-$SWIFT_PLATFORM

# Build Dependencies
ENV BUILD_DEPS build-essential wget clang-3.6 curl libedit-dev python2.7 python2.7-dev libicu52 rsync libxml2 git openssl libssl-dev libmysqlclient-dev

# Runtime Dependencies
ENV RUNTIME_DEPS ca-certificates krb5-locales libasn1-8-heimdal libcurl3 libgssapi-krb5-2 libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhx509-5-heimdal libicu52 libidn11 libk5crypto3 libkeyutils1 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2 libmysqlclient18 libroken18-heimdal librtmp0 libsasl2-2 libsasl2-modules libsasl2-modules-db libwind0-heimdal libxml2 mysql-common openssl sgml-base xml-core

# Compiler Flags
ENV COMPILER_FLAGS -Xswiftc -I/usr/local/mysql/include -Xlinker -L/usr/local/mysql/lib -Xswiftc -DNOJSON

# Init Apt
RUN apt-get update

# Install build dependencies
RUN apt-get install -y $BUILD_DEPS

# Setup clang
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - && \
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Install and verify Swift Ubuntu Snapshot
RUN SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_RELEASE/$SWIFT_ARCHIVE_NAME.tar.gz && \
    wget $SWIFT_URL && \
    wget $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
    rm -rf $SWIFT_ARCHIVE_NAME*

# Set Swift Path
ENV PATH /usr/bin:$PATH

# Directories
WORKDIR /$APP_NAME

# Copy sources
COPY . .

# Compile sources
RUN swift build --configuration release $COMPILER_FLAGS

# Remove build dependencies
RUN apt-get purge --auto-remove -y $BUILD_DEPS

# Install runtime dependencies
RUN apt-get install -y $RUNTIME_DEPS

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf App Packages Package.swift

# Setup App Binary
RUN mv .build bin && \
    ln -s bin/release/App $APP_NAME

# Set App Binary ass command
CMD ./$APP_NAME
