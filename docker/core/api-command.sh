#!/bin/bash
set -e
cd cikl-api
exec bundle exec puma config.ru
