#!/bin/bash
set -e
cd cikl-scheduler
exec bundle exec rackup
#exec /elasticsearch/bin/elasticsearch
