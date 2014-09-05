#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $TRAVIS_BUILD_DIR/src/ruby
# Speed up bundler installs
export BUNDLE_JOBS=7
rake bundle:clean
rake bundle:install
popd
