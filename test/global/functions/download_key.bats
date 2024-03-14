#!/usr/bin/env bats
# bats file_tags=server,functions

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
    HOST=$(testServer)
    TEST_FILE=$(mktemp -u)
    TEST_DIR=$(mktemp -d)
    echo "TEST_FILE: ${TEST_FILE}"
}

teardown() {
    rm -f "$TEST_FILE"
    rm -rf "$TEST_DIR"
    echo "result: ${result}"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

_download_key() {
    echo $(download_key $@)
}

@test "Invalid parameters" {
    result=$(_download_key)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid download key parameters" ]]

    result=$(_download_key "$HOST")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid download key parameters" ]]

    result=$(_download_key "$HOST" "folder")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid download key parameters" ]]
}

@test "Invalid FOLDER parameter" {
    result=$(_download_key "$HOST" "$TEST_FILE" "any")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Path download key is not a folder" ]]
}

@test "Success caching file cache" {
    
    [[ ! -f "$TEST_DIR/global/cache.sh" ]]

    result=$(_download_key "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]
    [[ "$result" == "$TEST_DIR/global/cache.sh" ]]
}

@test "Success caching twice file cache" {
    
    [[ ! -f "$TEST_DIR/global/cache.sh" ]]

    result=$(_download_key "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]

    result=$(_download_key "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]
}
