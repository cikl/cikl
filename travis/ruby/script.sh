#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $TRAVIS_BUILD_DIR/src/ruby
export RUBYOPT="-I$TRAVIS_BUILD_DIR/src/ruby/cikl-event/lib"
rake test:all
popd
