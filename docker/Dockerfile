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

# Install the bundle
RUN gem install /pkg/middleman-hashicorp-*.gem \
  && rm -rf /pkg

# Mounts
WORKDIR /website

ENTRYPOINT ["bundle", "exec", "middleman"]

CMD ["server"]

# docker run -v="$(pwd):/website" -p=4567:4567 hashicorp/middleman-hashicorp
