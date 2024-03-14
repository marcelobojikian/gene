#!/usr/bin/env bats
# bats file_tags=server,functions

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
    export URI=$(testServer)
    export LOG_LEVEL=ERROR
    export CACHE_PATH=$(mktemp -d)
    export CACHEABLE=false
    result=

    echo "CACHE_PATH: ${CACHE_PATH}"
}

teardown() {
    rm -rf "$CACHE_PATH"
    echo "result: ${result}"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

_launcher() {
    echo $(launcher $@)
}

@test "Invalid URL" {
    URI=
    result=$(_launcher)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid url to download" ]]
}

@test "Cachable true but without path" {
    CACHEABLE=true
    CACHE_PATH=
    result=$(_launcher)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Set cache path" ]]
}

@test "Cachable true but invalid path" {
    CACHEABLE=true
    CACHE_PATH=$(mktemp -u)
    result=$(_launcher)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid cache path: $CACHE_PATH" ]]
}

@test "Success launcher usage (no cacheable)" {
    result=$(_launcher usage/en/cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"usage/en/cache" ]]
}

@test "Success launcher command (no cacheable)" {
    result=$(_launcher cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh" ]]
}

@test "Success launcher command with large parameters" {
    result=$(_launcher cache --teste=true enable)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh --teste=true enable" ]]
}

@test "Success launcher command with small parameters" {
    result=$(_launcher cache -t true enable)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh -t true enable" ]]
}

@test "Success launcher command cacheable" {
    CACHEABLE=true
    result=$(_launcher cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh" ]]

    [[ -f "$CACHE_PATH/global/cache.sh" ]]
}

@test "Success launcher usage cacheable" {
    CACHEABLE=true
    result=$(_launcher usage/en/cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"usage/en/cache" ]]

    [[ -f "$CACHE_PATH/usage/en/cache" ]]
}