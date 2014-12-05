#!/bin/bash
set -e
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
pushd $PROJECT_DIR
export BUNDLE_JOBS=7
export BUNDLE_GEMFILE=$PROJECT_DIR/Gemfile
bundle install
popd
