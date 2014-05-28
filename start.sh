#!/bin/bash

. lib.sh

T1=$(date +%s.%N)

log "Building platform from the source code...." debug
init
log "Successfully compiled platform source code" info

log "Starting marmotta backend...." debug
exec "mvn tomcat7:run" "marmotta"
sleep 5
log "Applying custom configurations...." debug
config "kiwi.context" $PROXY_URL
config "kiwi.host" $MARMOTTA_URL
config "kiwi.setup.host" "true"
config "ldp.force_uri" "true"
log "Marmotta backend started at $MARMOTTA_URL" info

log "Starting proxy...." debug
exec "mvn exec:java -DskipTests" "proxy"
log "LDP Extraction proxy started at $PROXY_URL" debug

T2=$(date +%s.%N)
dt=$(echo "$T2 - $T1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
runtime=$(printf "%d:%02d:%02d:%02.4f" $dd $dh $dm $ds)
log "(total time: $runtime)" debug
log "Fusepool P3 platform successfully started!" info
log "logs available at target/*.log" warn
