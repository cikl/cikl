#!/bin/bash
set -e
export COVERAGE_DIR=/data/coverage
bundle exec rake test:unit
