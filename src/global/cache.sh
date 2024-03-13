#!/usr/bin/env bash

set -e

# Variables
CACHE_PATH=

# Functions
canonical() { 
  echo $(eval dirname "$1")/$(basename "$1")
}

die() { 
  printf "${@}\nTry 'gene cache -h' for more information.\n"
  exit 1
}

main() {

  [ "${1#\-}" == "p" ] && shift 2

  [ -z "$1" ] && die "No command or option."
  local target=$1
  shift

  [ -z "$CACHE_PATH" ] && die "Set cache path"
  [ ! -d "$CACHE_PATH" ] && die "Invalid cache path"

  [ "$target" != "enable" ] && [ ! -d "$CACHE_PATH" ] && die "Enable cache first."

  case $target in
    "enable") mkdir -p "$CACHE_PATH" ;;
    "delete") rm -r $CACHE_PATH ;;
    "get")
      [ -z "$1" ] && die "Cache get command requires one parameter"
      local KEY="$CACHE_PATH/$1"
      [ ! -f "$KEY" ] && echo "Cache not found: $KEY" && exit 1
      echo $KEY
    ;;
    "put")
      [ -z "$1" ] || [ -z "$2" ] && die "Cache put command requires two parameters"
      local KEY="$CACHE_PATH/$1"
      local FILE="$2"
      [ ! -f "$FILE" ] && echo "File not found: $KEY" && exit 1
      mkdir -p $(dirname "$KEY")
      mv "$FILE" "$KEY"
      echo $KEY
    ;;
    *) die "Invalid command: $target";;
  esac
}

# Main
while getopts ':p:-:' OPTION ; do
    case "$OPTION" in
    p ) CACHE_PATH=$(canonical "$OPTARG") ;;
    - ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo $OPTION | cut -d'=' -f2)
         OPTION=$(echo $OPTION | cut -d'=' -f1)
         case $OPTION in
            --path) CACHE_PATH=$(canonical "$OPTARG") ;;
            * ) die "Invalid option: $OPTARG " ;;
         esac
       OPTIND=1
       shift
      ;;
    ? ) die "Invalid option: $OPTARG " ;;
    esac
done

main $@