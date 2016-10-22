FROM ruby:2.3-alpine
MAINTAINER Seth Vargo <seth@hashicorp.com>

# Install packages
RUN apk add --no-cache build-base nodejs python py-setuptools

# Install s3cmd
ADD https://github.com/s3tools/s3cmd/releases/download/v1.6.1/s3cmd-1.6.1.tar.gz /s3cmd-1.6.1.tar.gz
RUN tar -xzvf /s3cmd-1.6.1.tar.gz && \
  cd /s3cmd-1.6.1 && \
  python setup.py install && \
  rm -rf /s3cmd-1.6.1*

# Add the context
ADD pkg/ /pkg

# Upgrade bundler
RUN gem update --no-document

# Install the bundle
RUN gem install /pkg/middleman-hashicorp-*.gem --no-document \
  && rm -rf /pkg

RUN gem list | grep mini

# For some reason, this isn't installed by default
# RUN gem install minitest --version "~> 5.9"

# Mounts
WORKDIR /website

# Expose ports
EXPOSE 4567
EXPOSE 35729

ADD docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["server"]
