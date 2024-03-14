#!/usr/bin/env bats
# bats file_tags=cache

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    _path global
    TEST_FILE=$(mktemp)
    TEST_DIR=$(mktemp -d)
    echo "TEST_DIR: ${TEST_DIR}"
}

teardown() {
    rm -f "$TEST_FILE"
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "Invalid when option is after command" {
    run cache.sh get --path=$TEST_DIR    
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid when command without path" {
    run cache.sh get     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid without second parameter" {
    run cache.sh --path=$TEST_DIR get
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache get command requires one parameter" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Success when Get cache with key " {

    KEY="123/XYZ"
    mkdir -p $(dirname "$TEST_DIR/$KEY")
    > "$TEST_DIR/$KEY"

    run cache.sh --path="$TEST_DIR" get "$KEY"
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "$TEST_DIR/$KEY" ]]

}

@test "Fail when key not exist" {

    KEY="123/XYZ"

    run cache.sh --path=$TEST_DIR get $KEY
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache not found: $TEST_DIR/$KEY" ]]

}
