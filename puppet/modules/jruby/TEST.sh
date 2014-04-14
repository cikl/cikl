#!/bin/sh

# BASEDIR=$(dirname $0)
# echo $BASEDIR
# echo $HOME
# pushd sandbox
puppet apply --debug  --execute "class{'jruby': }"

