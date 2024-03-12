#!/usr/bin/env bash
# https://bats-core.readthedocs.io/en/stable/tutorial.html

export PROJECT_ROOT="$( cd "$(pwd)/.." >/dev/null 2>&1 && pwd )"

server_pid=
server_on(){
    cd $PROJECT_ROOT/src
    python3 -m http.server 2>/dev/null &
    server_pid=$!
}
server_off(){
    kill $server_pid
}

cd $PROJECT_ROOT/test

../third/bats/bin/bats -p global/cache

server_on

../third/bats/bin/bats -p global/functions

server_off
