#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh

pushd p5-Cikl/
perl Build.PL && ./Build && ./Build test
popd

pushd p5-Cikl-RabbitMQ/
perl Build.PL && ./Build && ./Build test
popd
