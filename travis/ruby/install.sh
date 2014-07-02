#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd cikl-worker/
bundle install --without development
popd
pushd cikl-api/
bundle install --without development
popd
