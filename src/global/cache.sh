#!/usr/bin/env bash

canonical() { echo $(eval dirname "$1")/$(basename "$1"); }
error_message() { echo $@ && echo "Try 'gene cache -h' for more information." &&  exit 1; }
request_one_param() { [ -z "$1" ] && error_message "One o more paramaters failed."; }
required_two_param() { [ -z "$1" ] || [ -z "$2" ] && error_message "One o more paramaters failed."; }

CACHE_PATH=

while getopts ':p:-:' OPTION ; do
    case "$OPTION" in
    p ) CACHE_PATH=$(canonical "$OPTARG") ;;
    - ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo $OPTION | cut -d'=' -f2)
         OPTION=$(echo $OPTION | cut -d'=' -f1)
         case $OPTION in
            --path) CACHE_PATH=$(canonical "$OPTARG") ;;
            * ) error_message "Invalid option: $OPTARG " ;;
         esac
       OPTIND=1
       shift
      ;;
    ? ) error_message "Invalid option: $OPTARG " ;;
    esac
done

[[ -z "$1" ]] && error_message "No command or option."
[[ "$1" =~ ^-p ]] && shift && shift
target=$1
shift

[ -z "$CACHE_PATH" ] && error_message "Set cache path"
[ ! -d "$CACHE_PATH" ] && error_message "Invalid cache path"

[ "$target" != "enable" ] && [ ! -d "$CACHE_PATH" ] && error_message "Enable cache first."

case $target in
  "enable")    
    mkdir -p "$CACHE_PATH"
  ;;
  "delete")  
    rm -r $CACHE_PATH
  ;;
  "get")
    request_one_param $@
    KEY="$CACHE_PATH/$1"
    [ ! -f "$KEY" ] && echo "Cache not found: $KEY" && exit 1
    echo $KEY
  ;;
  "put")
    required_two_param $@
    KEY="$CACHE_PATH/$1"
    FILE="$2"
    [ ! -f "$FILE" ] && echo "File not found: $KEY" && exit 1
    mkdir -p $(dirname "$KEY")
    mv "$FILE" "$KEY"
    echo $KEY
  ;;
  *)
    error_message "Invalid command: $target"
  ;;
esac