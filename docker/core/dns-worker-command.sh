#!/bin/bash
set -e
cd cikl-worker
exec bundle exec ruby bin/dns_worker.rb config/config-cikl-worker-dns.yaml
