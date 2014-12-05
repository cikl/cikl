#!/bin/bash -x
set -e
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $TRAVIS_BUILD_DIR/src
# Speed up bundler installs
export BUNDLE_JOBS=7
export BUNDLE_GEMFILE=$TRAVIS_BUILD_DIR/src/Gemfile.core
bundle install
popd
