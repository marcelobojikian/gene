#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    methods "global/functions.sh"
    HOST=$(server)
    TEST_FILE=$(mktemp)
    TEST_DIR=$(mktemp -d)
    echo "TEST_FILE: ${TEST_FILE}"
    echo "TEST_DIR: ${TEST_DIR}"
    result=
}

teardown() {
    rm -f "$TEST_FILE"
    rm -rf "$TEST_DIR"
    echo "result: ${result}"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

_cache() {
    echo $(cache $@)
}

@test "Invalid parameters" {
    result=$(_cache)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid cache parameters" ]]

    result=$(_cache "$HOST")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid cache parameters" ]]

    result=$(_cache "$HOST" "folder")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid cache parameters" ]]
}

@test "Cache caching it self" {

    [[ ! -f "$TEST_DIR/global/cache.sh" ]]

    result=$(_cache "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]
    
    [[ "$result" == "$TEST_DIR/global/cache.sh" ]]
}

@test "Cache caching usage" {
    
    [[ ! -f "$TEST_DIR/usage/en/cache" ]]
    
    result=$(_cache "$HOST" "$TEST_DIR" "usage/en/cache")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]

    [[ -f "$TEST_DIR/usage/en/cache" ]]
    [[ "$result" == "$TEST_DIR/usage/en/cache" ]]

}