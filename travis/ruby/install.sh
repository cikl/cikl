#!/bin/bash -x -e
pushd cikl-worker/
bundle install --without development
popd
pushd cikl-api/
bundle install --without development
popd
