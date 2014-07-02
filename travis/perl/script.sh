#!/bin/bash -x -e

pushd p5-Cikl/
perl Build.PL && ./Build && ./Build test
popd

pushd p5-Cikl-RabbitMQ/
perl Build.PL && ./Build && ./Build test
popd
