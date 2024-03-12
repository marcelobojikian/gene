#!/usr/bin/env bash

DEFAULT_CONF=~/.gene/conf.txt
TRY_MESSAGE="Try 'gene -h' for more information."

export LOG_LEVEL=
export URI=
export CACHE_PATH=
export CACHEABLE=false

target=

[[ ! "$1" =~ ^- && ! "$1" =~ ^-- ]] && target=$1 && shift

_get_config() {
  local var=$(cat "$1" | grep "$2")
  [[ $var = *"="* ]] && echo $(echo $var | cut -d'=' -f2)
}

_uri() {

  if [ -z $URI ] ; then
    if [ -f "$DEFAULT_CONF" ] ; then
      URI="$(_get_config "$DEFAULT_CONF" "URI")"
      [ -z "$URI" ] && echo "Default URI not found" && exit 1
    fi
  fi

}

_cache_path() {

  if [ -z $CACHE_PATH ] ; then
    if [ -f "$DEFAULT_CONF" ] ; then
      CACHE_PATH="$(_get_config "$DEFAULT_CONF" "CACHE_PATH")"
    fi
  fi

}

_log_level() {

  if [ -z $DEFAULT_LOG_LEVEL ] ; then
    if [ -f "$DEFAULT_CONF" ] ; then
      DEFAULT_LOG_LEVEL="$(_get_config "$DEFAULT_CONF" "LOG_LEVEL")"
    fi
  fi

}

_functions() {

  local FUNCTIONS_KEY="global/functions.sh"
  local FUNCTIONS_FILE="$(_get_config "$DEFAULT_CONF" "FUNCTIONS")"

  if [ -z $FUNCTIONS_FILE ] ; then
    source <(curl -sSL "$URI/$FUNCTIONS_KEY")
  else
    if [ ! -f $FUNCTIONS_FILE ] ; then
      mkdir -p $(dirname "$FUNCTIONS_FILE")
      curl -sSLo "$FUNCTIONS_FILE" "$URI/$FUNCTIONS_KEY"
    fi
    source "$FUNCTIONS_FILE"
  fi

}

_command() {

  [ -z $target ] && _usage

  _uri
  _cache_path
  _log_level
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
  target="usage/$LANG/${target:-gene}"
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

_command $@