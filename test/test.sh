#!/usr/bin/env bash
# https://bats-core.readthedocs.io/en/stable/tutorial.html

export PROJECT_ROOT="$( cd "$(pwd)/.." >/dev/null 2>&1 && pwd )"

launch(){ $PROJECT_ROOT/third/bats/bin/bats -p $PROJECT_ROOT/test/$1; }

server_pid=
server_on(){
    cd $PROJECT_ROOT/src
    python3 -m http.server 2>/dev/null &
    server_pid=$!
}
server_off(){ kill $server_pid; }


launch global/cache
launch global/functions/log.bats
launch global/functions/command_key.bats

server_on

launch global/functions/cache.bats
launch global/functions/download_key.bats
launch global/functions/download.bats
launch global/functions/launcher.bats

server_off
