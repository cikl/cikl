#!/bin/bash -x
set -e
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $TRAVIS_BUILD_DIR/src/ruby
# Speed up bundler installs
export BUNDLE_JOBS=7
bundle install
popd
