FROM ruby:2.3-alpine
MAINTAINER Seth Vargo <seth@hashicorp.com>

ARG GEM_VERSION

# Install packages
RUN apk add --no-cache bash build-base curl jq nodejs python py-setuptools wget git openssh-client

# Install s3cmd
RUN cd /tmp && \
  wget https://github.com/s3tools/s3cmd/releases/download/v1.6.1/s3cmd-1.6.1.tar.gz && \
  tar -xzvf s3cmd-1.6.1.tar.gz && \
  cd s3cmd-1.6.1 && \
  python setup.py install && \
  cd .. && \
  rm -rf s3cmd-1.6.1*

# Upgrade bundler
RUN gem install bundler -v '~> 1.13' --no-document && \
  gem cleanup

# Install the bundle
RUN GEM_PATH="${GEM_HOME}" gem install middleman-hashicorp -v "${GEM_VERSION}" --no-document

# Mounts
WORKDIR /website

# Expose ports
EXPOSE 4567
EXPOSE 35729

ADD docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bundle", "exec", "middleman", "server"]
