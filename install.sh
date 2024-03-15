#!/usr/bin/env bash
##########################################################################
# Shellscript:	synopsis - Installs Gene program
# Author     :	Marcelo Nogueira <marcelo.bojikian@gmail.com>
# Date       :	2024-03-15
# Category   :	System Installer
##########################################################################
# Reference
# Gene       : https://github.com/marcelobojikian/gene
##########################################################################
# Description
#   Download and Install gene program on Ubuntu
#
##########################################################################

################################################# variables
readonly PROJECT_ROOT=https://github.com/marcelobojikian/gene/raw/main

readonly COMMAND_NAME=gene
readonly COMMAND_PATH_CONF=$HOME/.gene
readonly PROGRAM_ENV_FILE=$COMMAND_PATH_CONF/environment.conf
###########################################################

############################################## dependencies
for check in 'curl' ; do
    if ! which "$check" &> /dev/null
        then echo "Must have $check installed" && exit 1
    fi
done
###########################################################

################################################# functions

log() { msg="${@:2}"; printf "$(date "+%Y-%m-%d %H:%M:%S") - [%s] - %s\n" "${1^^}" "${msg}"; }

setup() {
    log info Config Path: $COMMAND_PATH_CONF
    mkdir -p "$COMMAND_PATH_CONF"
    mkdir -p "$COMMAND_PATH_CONF/cache"

    log info Set default configuration on path $PROGRAM_ENV_FILE
    cat <<EOF > $PROGRAM_ENV_FILE
URI=$PROJECT_ROOT/src
CACHEABLE=true
CACHE_PATH=$COMMAND_PATH_CONF/cache
FUNCTIONS=$COMMAND_PATH_CONF/cache/global/functions.sh
LOG_LEVEL=ERROR
EOF
}

download() {

    log info Download command $COMMAND_NAME from $PROJECT_ROOT

    local TO=/usr/local/sbin/$COMMAND_NAME
    sudo curl -sSLo "$TO" --progress-bar "$PROJECT_ROOT/src/command.sh" && sudo chmod +x "$TO"

}

install(){
    log info Enable cache on path $COMMAND_PATH_CONF/cache
    log info "Gene installed: $($COMMAND_NAME --uri=$PROJECT_ROOT -v)"
    # $COMMAND_NAME --uri=$PROJECT_ROOT --cache-path="$COMMAND_PATH_CONF/cache" -v
}
###########################################################

################################################# Principal
log info Instalando Home Lab library
setup
download
install
log info Instalacao completa