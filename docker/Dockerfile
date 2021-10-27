FROM docker.mirror.hashicorp.services/ruby:2.7.4-alpine

ARG GEM_VERSION

# Install packages
RUN apk add --no-cache bash build-base ca-certificates curl jq nodejs python3 py3-setuptools wget git openssh-client

# Install s3cmd
RUN cd /tmp && \
  curl -L -O https://github.com/s3tools/s3cmd/releases/download/v2.2.0/s3cmd-2.2.0.tar.gz && \
  tar -xzvf s3cmd-2.2.0.tar.gz && \
  cd s3cmd-2.2.0 && \
  python3 setup.py install && \
  cd .. && \
  rm -rf s3cmd-2.2.0*

# Upgrade bundler
RUN gem install bundler -v '~> 1.17' --no-document && \
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
