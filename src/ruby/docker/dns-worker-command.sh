#!/bin/bash
set -e
cd /opt/cikl/ruby/cikl-worker
exec bundle exec ruby bin/dns_worker.rb config/config-cikl-worker-dns.yaml
