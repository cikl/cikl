#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $PROJECT_DIR
bundle exec rake spec:all
popd
