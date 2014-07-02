#!/bin/bash -x
source $TRAVIS_BUILD_DIR/travis/error_handler.sh
cpanm --quiet --installdeps --notest ./p5-Cikl
cpanm --quiet --installdeps --notest ./p5-Cikl-RabbitMQ
