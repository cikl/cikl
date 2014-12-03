#!/bin/bash
set -e
cd /opt/cikl/ruby
export COVERAGE_DIR=/data/coverage
exec bundle exec rake test:all
