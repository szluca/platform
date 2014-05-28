#!/bin/bash

BUILD_DIR='target'
MARMOTTA_URL='http://localhost:8080'
PROXY_URL='http://localhost:8181'
CURL_OPTS="${CURL_OPTS:-"-sfS"}"

function init() {
  set +x
  mvn -q clean install -DskipTests
  mkdir -p $BUILD_DIR
  rm -f $BUILD_DIR/*.pid
  rm -f $BUILD_DIR/*.log
}

function log() {
  local c n
  if [ "$1" == "-n" ]; then
    n="-n"
    shift
  fi

  case "$2" in
  error) c="0;31" ;;
  info) c="0;32" ;;
  warn) c="1;35" ;;
  debug) c="0;34" ;;
  *) c="1;37" ;; #white
  esac
  echo $n -e "\e[0${c}m\033[1m${1}\e[00m"
}

url_encode() {
    python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" "$1"
}

config() {
  local KEY DATA
  KEY="$1"
  shift
  if [ $# -eq 0 ]; then
    curl $CURL_OPTS -X GET "${MARMOTTA_URL}/config/data/$(url_encode "$KEY")"
  else
    DATA="$(printf ',"%s"' "$@")"
    DATA="[${DATA:1}]"
    curl $CURL_OPTS -X POST -H "Content-Type: application/json" -d "$DATA" "${MARMOTTA_URL}/config/data/$(url_encode "$KEY")" \
        || { err=$?; log "Setting config $KEY failed: ($err)" error && return $err; }
    log "successfully set $KEY = $DATA" debug
  fi
}

function exec() {
  local CMD NAME
  CMD=$1
  NAME=$2
  cd $NAME
  echo $CMD
  $CMD >../$BUILD_DIR/$NAME.log 2>../$BUILD_DIR/$NAME.log & echo $! > ../$BUILD_DIR/$NAME.pid
  cd ..
}

