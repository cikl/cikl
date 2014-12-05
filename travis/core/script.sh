#!/bin/bash -x
set -e
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $TRAVIS_BUILD_DIR/src
export BUNDLE_GEMFILE=$TRAVIS_BUILD_DIR/src/Gemfile.core
bundle exec rake test:all
popd
