#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh

pushd $PROJECT_DIR
perl Build.PL && ./Build && ./Build test
popd
