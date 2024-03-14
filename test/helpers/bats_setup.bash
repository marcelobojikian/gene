#!/usr/bin/env bash

loadThirdHelpers() {
    load "$PROJECT_ROOT/third/test_helper/bats-support/load"
    load "$PROJECT_ROOT/third/test_helper/bats-assert/load"  
}
loadMethods() { . "$PROJECT_ROOT/src/${1}"; }

testServer() { echo http://localhost:8000; }

setSrcPath() { PATH="$PROJECT_ROOT/src:$PATH"; }
setPath() { PATH="$PROJECT_ROOT/src/${1}:$PATH"; }

getEnvIn() { local FILE=$(mktemp -p "$1"); for i in ${@:2}; do echo "$i" >> $FILE; done; echo $FILE; }
getEnv() { local FILE=$(mktemp); for i in ${@}; do echo "$i" >> $FILE; done; echo $FILE; }


