#!/bin/bash
set -e
cd /opt/cikl/ruby/cikl-api
exec puma config.ru
