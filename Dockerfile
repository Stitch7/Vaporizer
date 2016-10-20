# adapted from https://github.com/swiftdocker/docker-swift
# once docker-swift supports setting the swift version via a build-arg we could pull from there instead

FROM ubuntu:14.04

ENV SWIFT_BRANCH development
ARG SWIFT_VERSION
ENV SWIFT_VERSION ${SWIFT_VERSION}
ENV SWIFT_PLATFORM ubuntu14.04

# Install related packages
RUN apt-get update && \
    apt-get install -y build-essential wget clang libedit-dev python2.7 python2.7-dev libicu52 rsync libxml2 git libmysqlclient-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - && \
    gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Install Swift Ubuntu 14.04 Snapshot
RUN SWIFT_ARCHIVE_NAME=swift-$SWIFT_VERSION-$SWIFT_PLATFORM && \
    SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/swift-$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
    wget -q $SWIFT_URL && \
    wget -q $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
    rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*


#RUN bash -l -c 'echo export MYSQL_HOST="$(ip route show 0.0.0.0/0 | grep -Eo '"'"'via \S+'"'"' | awk '"'"'{ print $2 }'"'"')" >> /etc/bash.bashrc'
#RUN bash -l -c 'echo export MYSQL_HOST="$(ip route show 0.0.0.0/0 | grep -Eo '"'"'via \S+'"'"' | awk '"'"'{ print $2 }'"'"')" > /etc/profile.d/docker_init.sh'

#'"'"'
# export MYSQL_HOST="$(ip route show 0.0.0.0/0 | grep -Eo 'via \S+' | awk '{ print $2 }')"

# Set Swift Path
ENV PATH /usr/bin:$PATH

# vapor specific part

WORKDIR /vapor
VOLUME /vapor
EXPOSE 8080

#ENV MYSQL_HOST 172.17.0.1

#ENV MYSQL_HOST $(ip route show 0.0.0.0/0 | grep -Eo 'via \S+' | awk '{ print $2 }')

# mount in local sources via:  -v $(PWD):/vapor
# the vapor CLI command does this

CMD export MYSQL_HOST="$(ip route show 0.0.0.0/0 | grep -Eo 'via \S+' | awk '{ print $2 }')" && swift build -Xswiftc -DNOJSON && .build/debug/App
#CMD bash -l -c 'swift build -Xswiftc -DNOJSON && export MYSQL_HOST="$(ip route show 0.0.0.0/0 | grep -Eo '"'"'via \S+'"'"' | awk '"'"'{ print $2 }'"'"')"; .build/debug/App'
#CMD swift build -Xswiftc -DNOJSON && .build/debug/App

