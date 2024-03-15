#!/usr/bin/env bash
##########################################################################
# Shellscript:	synopsis - test all file using bats
# Author     :	Marcelo Nogueira <marcelo.bojikian@gmail.com>
# Date       :	2024-03-14
# Category   :	System Test
##########################################################################
# Reference
# bats-core  : https://bats-core.readthedocs.io/en/stable/tutorial.html
##########################################################################
# Description
#   Exports the project location variable.
#   Launches all tests by file, folder or tags.
#
##########################################################################

export PROJECT_ROOT="$( cd "$(pwd)/.." >/dev/null 2>&1 && pwd )"
launcher="$PROJECT_ROOT/third/bats/bin/bats"

launch(){ [ $# -eq 0 ] && $launcher -prT "$PROJECT_ROOT/test" || $launcher -pT "$PROJECT_ROOT/test/$1" ; }
launch_tag(){ $launcher -pTr "$PROJECT_ROOT/test" --filter-tags "$1"; }

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
