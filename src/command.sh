#!/usr/bin/env bash

DEFAULT_CONF=~/.gene/conf.txt
TRY_MESSAGE="Try 'gene -h' for more information."

export LOG_LEVEL=
export URI=
export CACHE_PATH=
export CACHEABLE=false

target=

[ -f $DEFAULT_CONF ] && . $DEFAULT_CONF
[[ ! "$1" =~ ^- && ! "$1" =~ ^-- ]] && target=$1 && shift

_functions() {

  local FUNCTIONS_KEY="global/functions.sh"

  if [ -z $FUNCTIONS ] ; then
    source <(curl -sSL "$URI/$FUNCTIONS_KEY")
  else
    if [ ! -f $FUNCTIONS ] ; then
      mkdir -p $(dirname "$FUNCTIONS")
      curl -sSLo "$FUNCTIONS" "$URI/$FUNCTIONS_KEY"
    fi
    source "$FUNCTIONS"
  fi

}

_command() {

  _functions

  result=$(launcher "$target" $@)
  if [ $? -ne 0 ] ; then
    echo $result
    exit 1
  fi
  . $result
}

_usage() {
  local LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
  target="usage/$LANG/${1:-gene}"
}

_version() {
    echo "Version: 1.0" && exit 0
}

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
            * ) echo -e "Invalid option: $OPTARG \r\n$TRY_MESSAGE" && exit 1 ;;
         esac
       OPTIND=1
       shift
      ;;
    ? ) echo -e "Invalid option: $OPTARG \r\n$TRY_MESSAGE" && exit 1 ;;
    esac
done

[ -z $target ] && _usage $1 && shift

_command $@