#!/bin/bash
set -e
cd /opt/cikl/ruby/cikl-api
exec bundle exec puma config.ru
