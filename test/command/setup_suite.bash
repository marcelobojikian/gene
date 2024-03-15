#!/usr/bin/env bats

setup_suite() {
    export TMPDIR=$(mktemp -dt bats-gene-XXXXXX)
    export -f getEnv
}

getEnvIn() { local FILE=$(mktemp -p "$1"); for i in ${@:2}; do echo "$i" >> $FILE; done; echo $FILE; }
getEnv() {  local FILE=$(mktemp -p "$TMPDIR"); for i in ${@}; do echo "$i" >> $FILE; done; echo $FILE; }

teardown_suite() {
    rm -rf "$TMPDIR"
}