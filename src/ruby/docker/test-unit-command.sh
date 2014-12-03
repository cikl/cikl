#!/bin/bash
cd /opt/cikl/ruby
mkdir /data/coverage
export COVERAGE_ROOT=/data/coverage
bundle exec rake test:unit
