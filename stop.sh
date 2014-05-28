#!/bin/bash

. lib.sh

for f in $BUILD_DIR/*.pid; 
do
  pid=$(head -n 1 $f)
  log "stoping process $pid..." debug
  kill $pid
  sleep 2
done

log "Fusepool P3 platform should be stopped" info
