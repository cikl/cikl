#!/bin/bash -x
set -e
export PROJECT_DIR=$TRAVIS_BUILD_DIR/src/cikl-api
source $TRAVIS_BUILD_DIR/travis/common/rake-spec.sh
