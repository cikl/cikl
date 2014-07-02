#!/bin/bash -x -e
pushd cikl-worker/
bundle exec rake spec
popd
pushd cikl-api/
bundle exec rspec
popd
