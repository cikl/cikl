#!/bin/bash
set -e
if [ $# -ne 2 ]; then
  echo "Missing arguments. Please specify both a feed PROVIDER and NAME!"
  echo "  example: threatinator-run mirc domain_reputation"
  exit 1
fi

cd cikl-scheduler

bundle exec rake threatinator:run FEED_PROVIDER="$1" FEED_NAME="$2"
echo "Job queued. Monitor the scheduler web UI for progress."
