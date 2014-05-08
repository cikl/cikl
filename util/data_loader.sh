#!/bin/bash
# This script will create a tarball containing a snapshot of all data contained 
# within Cikl. This is intended for usage by developers of Cikl.
#
# Warning on doing a restore:
#   This will wipe out any data that you have within Elasticsearch!
#
# Usage: 
#   data_loader.sh dump my_snapshot.tgz
#   data_loader.sh restore my_snapshot.tgz
#

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

# Begin global variables
things_to_clean=( )
last_cleanup_offset=-1
ES_SNAPSHOT_NAME=dump
EXTRA_CURL_OPTS="-s"
# End global variables

register_cleanup() {
  last_cleanup_offset=$(($last_cleanup_offset + 1))
  things_to_clean[$last_cleanup_offset]="$@"
}

cleanup() {
  if [ $last_cleanup_offset -ge 0 ]; then
    for offset in $(seq 0 $last_cleanup_offset)
    do
      local _code=${things_to_clean[$offset]}
      debug "'$_code >/dev/null 2>&1'"
      eval "$_code >/dev/null 2>&1"
      [ $? -eq 0 ] || error "Cleanup exited with $?: $_code"
    done
  fi
}

trap cleanup 0

function es_create_repo () {
  [ "$#" -eq 2 ] || die "'es_create_repo' requires exactly 2 arguments. Got $#."
  local repo_name=$1
  local snapshot_path=$2

  notify "Elasticsearch: Creating repo named $repo_name, with data stored in $snapshot_path"
  STATUSCODE=$(curl -s -o /dev/stderr --write-out "%{http_code}" -XPUT "http://localhost:9200/_snapshot/${repo_name}?pretty" -d "{
      \"type\": \"fs\",
      \"settings\": {
          \"location\": \"${snapshot_path}\",
          \"compress\": true
      }
    }")
  [ $STATUSCODE -eq 200 ] || die "Failed to create snapshot repo: ${repo_name}. Got $STATUSCODE"

  register_cleanup "curl -Sf $EXTRA_CURL_OPTS -XDELETE 'http://localhost:9200/_snapshot/${repo_name}?pretty'"
}

function es_save_snapshot () {
  [ "$#" -eq 1 ] || die "'es_save_snapshot' requires exactly 1 argument. Got $#."
  local final_path=$1
  local repo_name=cikl.$(date +%s.%N)
  local snapshot_path=$(mktemp -d)
  register_cleanup "sudo rm -fr $snapshot_path"
  rm -fr $snapshot_path

  es_create_repo "$repo_name" "$snapshot_path"

  notify "Elasticsearch: taking snapshot"
  STATUSCODE=$(curl -s -o /dev/stderr --write-out "%{http_code}"  -XPUT "http://localhost:9200/_snapshot/${repo_name}/${ES_SNAPSHOT_NAME}?wait_for_completion=true&pretty")
  [ $STATUSCODE -eq 200 ] || die "Failed to take snapshot in: ${snapshot_path}. Got $STATUSCODE"

  cp -R $snapshot_path $final_path
}

function es_delete_indicies () {
  [ "$#" -eq 0 ] || die "'es_delete_indicies' requires exactly 0 arguments. Got $#."

  notify "Elasticsearch: deleting existing indicies"
  STATUSCODE=$(curl -s -o /dev/stderr --write-out "%{http_code}" -XDELETE "http://localhost:9200/*?pretty")
  [ $STATUSCODE -eq 200 ] || die "Failed to delete existing indicies. Got $STATUSCODE"
}

function es_restore_snapshot () {
  [ "$#" -eq 1 ] || die "'es_restore_snapshot' requires exactly 1 argument. Got $#."
  local snapshot_path=$1
  local repo_name=cikl.$(date +%s.%N)

  es_create_repo "$repo_name" "$snapshot_path"

  es_delete_indicies

  notify "Elasticsearch: restoring snapshot"
  STATUSCODE=$(curl -s -o /dev/stderr --write-out "%{http_code}" -XPOST "http://localhost:9200/_snapshot/${repo_name}/${ES_SNAPSHOT_NAME}/_restore?wait_for_completion=true&pretty")
  [ $STATUSCODE -eq 200 ] || die "Failed to restore elasticsearch snapshot ${ES_SNAPSHOT_NAME} from: ${snapshot_path}. Got $STATUSCODE"
}

function create_dump_archive () {
  [ "$#" -eq 2 ] || die "'create_dump_archive' requires exactly 2 arguments. Got $#."
  local archive_file=$1
  local archive_path=$2
  [ -e $archive_file ] && die "Output file already exists! $archive_file"
  [ -e $archive_path ] || die "Cannot find archive path: $archive_path"
  notify "Creating archive file $archive_file"
  tar czf "$archive_file" -C "$archive_path" .
  [ $? -eq 0 ] || die "Failed to create archive"
}

function cmd_dump () {
  [ "$#" -eq 1 ] || die "'dump' requires exactly 1 argument. Got $#."
  local archive_file=$1

  [ -e $archive_file ] && die "Output file already exists! $archive_file"

  local tmp_archive_path=$(mktemp -d)
  register_cleanup "rm -fr $tmp_archive_path"
  debug "tmp_archive_path = $tmp_archive_path"

  es_save_snapshot "$tmp_archive_path/es"
  create_dump_archive "$archive_file" "$tmp_archive_path"
}

function extract_archive() {
  [ "$#" -eq 2 ] || die "'extract_archive' requires exactly 2 arguments. Got $#."
  local archive_file=$1
  local archive_path=$2

  [ -f $archive_file ] || die "Cannot find archive file: $archive_file"
  [ -d $archive_path ] || die "Cannot find archive path: $archive_path"

  tar xzf $archive_file -C $archive_path
  [ $? -eq 0 ] || die "Failed to extract archive $archive_file to $archive_path"
  chmod 755 $archive_path
  [ $? -eq 0 ] || die "Failed set permissions on $archive_path"
}

function cmd_restore () {
  [ "$#" -eq 1 ] || die "'dump' requires exactly 1 argument. Got $#."
  local archive_file=$1

  [ -e $archive_file ] || die "Cannot find archive file: $archive_file"
  local tmp_archive_path=$(mktemp -d)
  register_cleanup "rm -fr $tmp_archive_path"

  extract_archive "$archive_file" "$tmp_archive_path"
  es_restore_snapshot "$tmp_archive_path/es"
}

_CMD=$1
shift
case $_CMD in
dump) 
  cmd_dump "$@"
  ;;
restore) 
  cmd_restore "$@"
  ;;
*) 
  die "Unknown command: '$_CMD'"
  ;;
esac

