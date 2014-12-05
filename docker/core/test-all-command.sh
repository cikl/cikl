#!/bin/bash
set -e
export COVERAGE_DIR=/data/coverage
exec bundle exec rake test:all
