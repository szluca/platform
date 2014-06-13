#!/bin/bash
#
# Copyright (C) 2014 Salzburg Research.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. lib.sh

T1=$(date +%s.%N)

log "Building platform from the source code...." debug
init
log "Successfully compiled platform source code" info

log "Starting marmotta backend...." debug
exec "mvn tomcat7:run" "marmotta"
sleep 5
log "Marmotta backend started at $MARMOTTA_URL" info

log "Starting proxy...." debug
exec "mvn exec:java -DskipTests" "proxy"
sleep 5
log "LDP Extraction proxy started at $PROXY_URL" debug
log "Successfully started Fusepool P3 platform!" info

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
