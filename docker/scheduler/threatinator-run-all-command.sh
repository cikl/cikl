#!/bin/bash
set -e

cd cikl-scheduler

bundle exec rake threatinator:run-all
echo "Job queued. Monitor the scheduler web UI for progress."
