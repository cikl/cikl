#!/bin/bash -x
set -e
export PROJECT_DIR=$TRAVIS_BUILD_DIR/src/cikl-worker
source $TRAVIS_BUILD_DIR/travis/common/bundle-install.sh
