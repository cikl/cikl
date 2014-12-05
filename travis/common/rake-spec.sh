#!/bin/bash
set -e
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $PROJECT_DIR
export BUNDLE_GEMFILE=$PROJECT_DIR/Gemfile
bundle exec rake spec:all
popd

