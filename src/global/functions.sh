
command_key(){

  declare -A targets
  
  targets[cache]=global
  targets[first-installer]=proxmox

  [[ ${!targets[@]} =~ $1 ]] && echo ${targets[$1]}/$1.sh || echo $1

}

log() {
  
  local severity=${1^^}
  [ -z $severity ] && severity=INFO
  shift

  local -A levels=( ['DEBUG']="7" ['INFO']="6" ['WARN']="4" ['ERROR']="3" ['FATAL']="2")
  [[ ! ${!levels[@]} =~ $severity ]] && echo "Invalid log" && return 1

  local LEVEL=${LOG_LEVEL^^}
  [ -z $LEVEL ] && LEVEL=ERROR

  local LOG="${levels[${LEVEL}]}"
  local lvl_msg="${levels[${severity}]:-3}"

  if [ $LOG -ge $lvl_msg ] ; then

    if [ -z $LOG_PATH ] ; then
      LOG_PATH=$HOME/.gene/log
      mkdir -p $LOG_PATH
    fi

    local message="${@}"
    printf "$(date "+%Y-%m-%d %H:%M:%S") [%s] %s\n" "${severity}" "${message}" >> "$LOG_PATH/$(date "+%Y-%m-%d").log"
    
  fi

}


download() {

    local URL=$1
    local DEST_FILE=$2
    
    local HTTP_CODE=$(curl -sLo "$DEST_FILE" -w "%{http_code}" "$URL")

    if [ ${HTTP_CODE} -eq 404 ] ; then
      log error Url not found: $URL
      echo Url not found: $URL
      rm -f "$DEST_FILE" && exit 1
    elif [ ${HTTP_CODE} -ne 200 ] ; then
      log error "Http error [${HTTP_CODE}] from: $URL"
      echo Unexpected fail: $URL
      rm -f "$DEST_FILE" && exit 2
    fi

}

download_key() {

  [ $# -lt 3 ] && echo "Invalid download key parameters" && exit 1
  [ ! -d "$2" ] && echo "Path download key is not a folder" && exit 1

  local KEY=$3

  local FROM_URL=$1/$KEY
  local TO_FILE=$2/$KEY

  if [ ! -f $TO_FILE ] ; then

    log info "Downloading from $FROM_URL"
    
    mkdir -p $(dirname "$TO_FILE")
    download "$FROM_URL" "$TO_FILE"
    chmod u+x "$TO_FILE"

  fi

  echo $TO_FILE

}

cache() {

  [ $# -lt 3 ] && echo "Invalid cache parameters" && exit 1

  local BASE_URL=$1
  local FOLDER=$2
  local KEY=$3

  log info "Loading program cache ..."
  local file_cache=$(download_key "$BASE_URL" "$FOLDER" "global/cache.sh")
  
  log info "Get $KEY from cache"
  local new_cmd_cached=$($file_cache -p "$FOLDER" get "$KEY")
  if [ -z $new_cmd_cached  ] ; then
    log info "File not cached yet, download it now."
    local new_file=$(download_key "$BASE_URL" "$(mktemp -d)" "$KEY")
    log info "Caching file $new_file on $FOLDER."
    new_cmd_cached=$($file_cache -p $FOLDER put "$KEY" "$new_file")
  fi

  echo $new_cmd_cached

}

launcher() {

  [ -z $URI ] && echo "Invalid url to download" && exit 1

  log info Searching: $1
  local KEY=$(command_key "$1")
  local PARAMS=${@:2}

  local SOURCE=$(mktemp -d)
  if [ "$CACHEABLE" == "true" ] ; then
    [ -z $CACHE_PATH ] && echo "Set cache path" && exit 1
    [ ! -d $CACHE_PATH ] && echo "Invalid cache path: $CACHE_PATH" && exit 1
    log info "Finding Cache [$KEY] from $CACHE_PATH"
    SOURCE=$(cache "$URI" "$CACHE_PATH" "$KEY")
  else
    log info "Download [$KEY] from $URI"
    SOURCE=$(download_key "$URI" "$SOURCE" "$KEY")
    chmod u+x "$SOURCE"
  fi

  log info Launcher: $SOURCE $PARAMS
  echo $SOURCE $PARAMS

}