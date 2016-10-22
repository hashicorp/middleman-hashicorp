#!/bin/sh
set -e

# Install any additional dependencies our bundle needs. Most of the core
# dependencies are already included in the container, so this just any
# additional things that were not originally present in the build.
if ! bundle check &>/dev/null; then
  echo "==> Warning! You have missing dependencies. This is probably okay but"
  echo "    it means your build is going to take a bit longer each time. You"
  echo "    may want to consider adding your requirements to the container for"
  echo "    a faster build."
  echo ""
  echo "==> Installing missing dependencies. This may take some time..."
  bundle install
fi

exec "$@"
