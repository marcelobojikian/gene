#!/usr/bin/env bats
# bats file_tags=server,functions

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
    export URI=$(testServer)
    export LOG_LEVEL=ERROR
    export CACHEABLE=false
    export CACHE_PATH=$(mktemp -dp "$TMPDIR")
}

teardown() {
    rm -rf "$CACHE_PATH"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

launch() {
    echo $(launcher $@)
}

@test "Should fail when URI is not informed" {
    URI=
    result=$(launch)
    [[ ! -z "$result" ]]
    [[ "${result}" == "Invalid url to download" ]]
}

@test "Should fail when cachable is true and the cache path is empty" {
    CACHEABLE=true
    CACHE_PATH=
    result=$(launch)
    [[ ! -z "$result" ]]
    [[ "${result}" == "Set cache path" ]]
}

@test "Should fail when cachable is true and the cache path is invalid" {
    CACHEABLE=true
    CACHE_PATH=$(mktemp -up "$TMPDIR")
    result=$(launch)
    [[ ! -z "$result" ]]
    [[ "${result}" == "Invalid cache path: $CACHE_PATH" ]]
}

@test "Should launch and show usage key (no cacheable)" {
    result=$(launch usage/en/cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"usage/en/cache" ]]
}

@test "Should launch and show command key (no cacheable)" {
    result=$(launch cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh" ]]
}

@test "Should launch with large parameters when it not exist" {
    result=$(launch cache --teste=true enable)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh --teste=true enable" ]]
}

@test "Should launch with small parameters when it not exist" {
    result=$(launch cache -t true enable)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh -t true enable" ]]
}

@test "Should launch and cache the command" {
    CACHEABLE=true
    result=$(launch cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"global/cache.sh" ]]

    [[ -f "$CACHE_PATH/global/cache.sh" ]]
}

@test "Should launch and cache the usage instruction" {
    CACHEABLE=true
    result=$(launch usage/en/cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"usage/en/cache" ]]

    [[ -f "$CACHE_PATH/usage/en/cache" ]]
}