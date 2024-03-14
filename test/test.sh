#!/usr/bin/env bash
# https://bats-core.readthedocs.io/en/stable/tutorial.html

export PROJECT_ROOT="$( cd "$(pwd)/.." >/dev/null 2>&1 && pwd )"
launcher="$PROJECT_ROOT/third/bats/bin/bats"

launch_tag(){ $launcher -pTr "$PROJECT_ROOT/test" --filter-tags "$1"; }
launch(){ [ $# -eq 0 ] && $launcher -prT "$PROJECT_ROOT/test/global/cache" || $launcher -pT "$PROJECT_ROOT/test/$1" ; }

server_pid=
server_on(){
    cd $PROJECT_ROOT/src
    python3 -m http.server 2>/dev/null &
    server_pid=$!
}
server_off(){ kill $server_pid; }

launch_tag !server

server_on
launch_tag server
server_off
