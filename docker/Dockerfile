FROM ruby:2.3-alpine
MAINTAINER Seth Vargo <seth@hashicorp.com>

ARG GEM_VERSION

# Install packages
RUN apk add --no-cache bash build-base curl jq nodejs python py-setuptools wget git

# Install s3cmd (specified sha contains fix for modify requests)
RUN cd /tmp && \
  wget -O s3cmd.tar.gz https://github.com/s3tools/s3cmd/archive/d5e61c3eb02a9b4e66d49fa0f1ad8279d007994b.tar.gz && \
  tar -xzvf s3cmd.tar.gz && \
  cd s3cmd-d5e61c3eb02a9b4e66d49fa0f1ad8279d007994b && \
  python setup.py install && \
  cd .. && \
  rm -rf s3cmd*

# Upgrade bundler
RUN gem update --no-document && \
  gem cleanup

# Install the bundle
RUN gem install middleman-hashicorp -v ${GEM_VERSION} --no-document

# Mounts
WORKDIR /website

# Expose ports
EXPOSE 4567
EXPOSE 35729

ADD docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bundle", "exec", "middleman", "server"]
