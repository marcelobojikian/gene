
command_key(){

  declare -A targets
  
  targets[cache]=global
  targets[first-installer]=proxmox

  [[ ${!targets[@]} =~ $1 ]] && echo ${targets[$1]}/$1.sh || echo $1

}

log() {
  
  local severity=$(echo "${1}" | awk '{print toupper($0)}')
  [ -z $severity ] && severity=FATAL
  shift

  local -A levels=( ['DEBUG']="7" ['INFO']="6" ['WARN']="4" ['ERROR']="3" ['FATAL']="2")
  [[ ! ${!levels[@]} =~ $severity ]] && echo "Invalid log" && return 1

  local LEVEL=$(echo "${LOG_LEVEL:-"ERROR"}" | awk '{print toupper($0)}')
  local LOG="${levels[${LEVEL}]}"

  local lvl_msg="${levels[${severity}]:-3}"
  local msg="[${severity}] ${@}";

  [ $LOG -ge $lvl_msg ] && echo -e $msg
  return 0
}

download() {

    local URL=$1
    local DEST_FILE=$2
    
    local HTTP_CODE=$(curl -sLo "$DEST_FILE" -w "%{http_code}" "$URL")

    if [ ${HTTP_CODE} -eq 404 ] ; then
      log debug URL: $URL
      log error Url not found: $URL
      rm -f "$DEST_FILE" && exit 1
    elif [ ${HTTP_CODE} -ne 200 ] ; then
      log debug URL: $URL
      log debug DEST_FILE: $DEST_FILE
      log error Downloaded fail: $URL
      rm -f "$DEST_FILE" && exit 2
    fi

}

download_key() {

  [ $# -lt 3 ] && log error "Invalid download key parameters" && exit 1
  [ ! -d "$2" ] && log error "Path download key is not a folder" && exit 1

  local KEY=$3

  local FROM_URL=$1/$KEY
  local TO_FILE=$2/$KEY

  if [ ! -f $TO_FILE ] ; then

    log debug "Caching file $TO_FILE"
    
    mkdir -p $(dirname "$TO_FILE")
    download "$FROM_URL" "$TO_FILE"
    chmod +x "$TO_FILE"

  fi

  echo $TO_FILE

}

cache() {

  [ $# -lt 3 ] && log error "Invalid cache parameters" && exit 1

  local BASE_URL=$1
  local FOLDER=$2
  local KEY=$3

  local file_cache=$(download_key "$BASE_URL" "$FOLDER" "global/cache.sh")
  
  local new_cmd_cached=$($file_cache -p "$FOLDER" get "$KEY" 1> /dev/null)
  if [ -z $new_cmd_cached  ] ; then
    local new_file=$(download_key "$BASE_URL" "$(mktemp -d)" "$KEY")
    new_cmd_cached=$($file_cache -p $FOLDER put "$KEY" "$new_file")
  fi

  echo $new_cmd_cached

}

launcher() {

  [ -z $URI ] && log error "Invalid url to download" && exit 1

  local KEY=$(command_key "$1")
  local PARAMS=${@:2}

  local SOURCE=$(mktemp -d)
  if [ "$CACHEABLE" == "true" ] ; then
    [ -z $CACHE_PATH ] && log error "Set cache path" && exit 1
    [ ! -d $CACHE_PATH ] && log error "Invalid cache path: $CACHE_PATH" && exit 1
    SOURCE=$(cache "$URI" "$CACHE_PATH" "$KEY")
  else
    SOURCE=$(download_key "$URI" "$SOURCE" "$KEY")
    chmod +x "$SOURCE"
  fi

  echo $SOURCE $PARAMS

}