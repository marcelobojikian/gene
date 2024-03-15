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

# Use test/setup_suite.sh
launch_all() {
    server_on
        launch
    server_off
}

# Use test/[EACH_FOLDER]/setup_suite.sh
launch_by_directory() {
    server_on
        launch global/cache
        launch global/functions
        launch command
    server_off
}

# Use test/[EACH_FOLDER]/setup_suite.sh
launch_by_name() {
    server_on

        launch global/cache/delete.bats
        launch global/cache/enable.bats
        launch global/cache/get.bats
        launch global/cache/getopt.bats
        launch global/cache/put.bats

        launch global/functions/cache.bats
        launch global/functions/command_key.bats
        launch global/functions/download_key.bats
        launch global/functions/download.bats
        launch global/functions/launcher.bats
        launch global/functions/log.bats

        launch command/file_environment.bats
        launch command/getopt.bats
        launch command/opt_cacheable.bats
        launch command/var_functions.bats

    server_off

}

# Use test/setup_suite.sh
launch_by_server() {
    launch_tag !server
    server_on
        launch_tag server
    server_off
}

# Using test/setup_suite.sh
launch_all

# Using test/[EACH_FOLDER]/setup_suite.sh
# launch_by_directory