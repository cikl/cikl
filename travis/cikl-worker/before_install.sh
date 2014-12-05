#!/bin/bash -x
set -e
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
sudo apt-get install libunbound2 unbound
