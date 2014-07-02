#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd cikl-worker/
bundle exec rake spec
popd
pushd cikl-api/
bundle exec rspec
popd
