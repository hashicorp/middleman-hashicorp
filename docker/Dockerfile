FROM ruby:2.3-slim
MAINTAINER HashiCorp

# Update the apt cache and install our required things
RUN apt-get update
RUN apt-get install -y build-essential curl git libffi-dev s3cmd wget

# Add the Gemfile so we can install the bundle
COPY Gemfile /Gemfile

# Install the bundle
RUN cd / && bundle install --jobs 7
