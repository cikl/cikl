#!/bin/bash
export RUBYOPT="$RUBYOPT -rset -I/opt/cikl/ruby/threatinator-output-cikl/lib"
exec threatinator "$@"
