#!/usr/bin/env bats
# bats file_tags=server,functions

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
    export HOST=$(testServer)
    export TEST_DIR=$(mktemp -dp "$TMPDIR")
}

teardown() {
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

launch() {
    echo $(download_key $@)
}

@test "Sould fail when informed less than 3 parameters" {
    result=$(launch)
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid download key parameters" ]]

    result=$(launch "$HOST")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid download key parameters" ]]

    result=$(launch "$HOST" "folder")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Invalid download key parameters" ]]
}

@test "Should fail when parameter folder is invalid" {
    result=$(launch "$HOST" "$(mktemp -up "$TMPDIR")" "any")
    [[ ! -z "$result" ]]
    [[ "${result}" == *"Path download key is not a folder" ]]
}

@test "Should download file cache.sh when requested" {
    
    [[ ! -f "$TEST_DIR/global/cache.sh" ]]

    result=$(launch "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]
    [[ "$result" == "$TEST_DIR/global/cache.sh" ]]
}

@test "Should download first time and retrive the same object in the second time" {
    
    [[ ! -f "$TEST_DIR/global/cache.sh" ]]
    result=$(launch "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]

    CREATED=$(stat -c '%x' "$TEST_DIR/global/cache.sh")

    result=$(launch "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]

    MODIFIED=$(stat -c '%x' "$TEST_DIR/global/cache.sh")

    [[ "$CREATED" == "$MODIFIED" ]]
}
