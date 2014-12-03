#!/bin/bash
set -e
cd cikl-scheduler
exec bundle exec sidekiq -r ./worker_env.rb
