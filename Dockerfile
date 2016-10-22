# adapted from https://github.com/swiftdocker/docker-swift
# once docker-swift supports setting the swift version via a build-arg we could pull from there instead

FROM ubuntu:14.04

ENV SWIFT_BRANCH swift-3.0-release
ARG SWIFT_VERSION
ENV SWIFT_VERSION ${SWIFT_VERSION}
ENV SWIFT_PLATFORM ubuntu14.04

# Install related packages and set LLVM 3.6 as the compiler
RUN apt-get update && \
    apt-get install -y build-essential wget clang-3.6 curl libedit-dev python2.7 python2.7-dev libicu52 rsync libxml2 git && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - && \
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Install Swift Ubuntu 14.04 Snapshot
RUN SWIFT_ARCHIVE_NAME=$SWIFT_VERSION-$SWIFT_PLATFORM && \
    SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
    wget $SWIFT_URL && \
    wget $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
    rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*

# Set Swift Path
ENV PATH /usr/bin:$PATH

# vapor specific part

WORKDIR /vapor
VOLUME /vapor
EXPOSE 8080

# mount in local sources via:  -v $(PWD):/vapor
# the vapor CLI command does this

CMD swift build && .build/debug/App
