#!/usr/bin/env bash
##########################################################################
# Shellscript:	synopsis - execute gene software
# Author     :	Marcelo Nogueira <marcelo.bojikian@gmail.com>
# Date       :	2024-03-15
# Category   :	System Main
##########################################################################
# Reference
# Gene       : https://github.com/marcelobojikian/gene
##########################################################################
# Description
#   Install and run modules independent of other repositories
#
##########################################################################

################################################# variables
ENV_FILE=

export URI=
export LOG_LEVEL=
export CACHE_PATH=
export CACHEABLE=false

target=
###########################################################

############################################## dependencies
for check in 'curl' ; do
    if ! which "$check" &> /dev/null
        then echo "Must have $check installed" && exit 1
    fi
done
###########################################################

################################################# functions
die() { printf "${@}\nTry 'gene -h' for more information.\n" && exit 1 ; }

_env() {

  [ ! -f $1 ] && die "Invalid configuration file: $1"
  ENV_FILE="$1"
  . "$ENV_FILE"
  
}

_functions() {

  [ -f $URI ] && die "Unknown uri, use option --uri to set valid url."

  local HTTP_CODE=200
  if [ -z $FILE_GLOBAL_FUNC ] ; then
    local FILE=$(mktemp -u)
    HTTP_CODE=$(curl -sLo "$FILE" -w "%{http_code}" "$URI/global/functions.sh")
    . "$FILE"
  else
    if [ ! -f $FILE_GLOBAL_FUNC ] ; then
      mkdir -p $(dirname "$FILE_GLOBAL_FUNC")
      HTTP_CODE=$(curl -sLo "$FILE_GLOBAL_FUNC" -w "%{http_code}" "$URI/global/functions.sh")
    fi
    . "$FILE_GLOBAL_FUNC"
  fi

  [ ${HTTP_CODE} -ne 200 ] && echo "Url invalida: ${URI}" && exit 1

}

_command() {

  _functions

  result=$(launcher "$target" $@)
  if [ $? -ne 0 ] ; then
    echo $result && exit 1    
  fi

  . $result

}

_usage() {
  local language=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
  target="usage/${language}/${1:-gene}"
}

_version() {
    echo "Version: 1.0" && exit 0
}
###########################################################

################################################# Principal

[[ ! "$1" =~ ^- && ! "$1" =~ ^-- ]] && target=$1 && shift

while getopts ':vhCc:l:-:' OPTION ; do
    case "$OPTION" in
    h ) _usage ;;
    v ) _version ;;
    C ) CACHEABLE=true ;;
    c ) CACHE_PATH="$OPTARG" && CACHEABLE=true ;;
    l ) LOG_LEVEL="$OPTARG" ;;
    - ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo $OPTION | cut -d'=' -f2)
         OPTION=$(echo $OPTION | cut -d'=' -f1)
         case $OPTION in
            --help) _usage ;;
            --version) _version ;;
            --cache-path) CACHE_PATH="$OPTARG" && CACHEABLE=true ;;
            --log-level) LOG_LEVEL="$OPTARG" ;;
            --uri) URI="$OPTARG" ;;
            --env-file) _env "$OPTARG" ;;
            * ) die "Invalid option: $OPTARG ";;
         esac
       OPTIND=1
       shift
      ;;
    ? ) die "Invalid option: $OPTARG " ;;
    esac
done

[ -z $ENV_FILE ] && . ~/.gene/environment.conf
[ -z $target ] && _usage $1 && shift

_command $@