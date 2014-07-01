#!/bin/bash
# Usage: 
#   drop_data.sh 

exec 3>&2 # logging stream (file descriptor 3) defaults to STDERR
verbosity=2 # default to show warnings
silent_lvl=0
err_lvl=1
wrn_lvl=2
inf_lvl=3
dbg_lvl=4

die () { error "$@"; exit 1; }
notify() { log $silent_lvl "NOTE: $1"; } # Always prints
error() { log $err_lvl "ERROR: $1"; }
warn() { log $wrn_lvl "WARNING: $1"; }
inf() { log $inf_lvl "INFO: $1"; } # "info" is already a command
debug() { log $dbg_lvl "DEBUG: $1"; }
log() {
  if [ $verbosity -ge $1 ]; then
    # Expand escaped characters, wrap at 70 chars, indent wrapped lines
    echo -e "$2" | fold -w70 -s | sed '2~1s/^/  /' >&3
  fi
}

curl -XDELETE http://localhost:9200/*
[ $? -eq 0 ] || die "Failed to clear out elasticsearch data"
mongo cikl /vagrant/util/drop_mongo.js
[ $? -eq 0 ] || die "Failed to drop mongodb database"
