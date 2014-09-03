#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $TRAVIS_BUILD_DIR/src/ruby
rake test:all
popd
