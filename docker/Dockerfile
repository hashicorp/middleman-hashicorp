FROM ruby:2.3-slim
MAINTAINER Seth Vargo <seth@hashicorp.com>

# Required packages
RUN \
  apt-get -qq update && \
  apt-get install -yqq build-essential git python-setuptools

# Install s3cmd
RUN \
  curl -sLo /s3cmd-1.6.1.tar.gz https://github.com/s3tools/s3cmd/releases/download/v1.6.1/s3cmd-1.6.1.tar.gz && \
  tar -xzvf /s3cmd-1.6.1.tar.gz && \
  cd /s3cmd-1.6.1 && \
  python setup.py install && \
  rm -rf /s3cmd-1.6.1*

# Install the bundle
RUN \
  gem install middleman-hashicorp --version "${VERSION}"

CMD (bundle check || bundle install) && \
  bundle exec middleman build --clean
