#!/bin/bash
set -e
cd /opt/cikl/ruby
export COVERAGE_DIR=/data/coverage
bundle exec rake test:unit
