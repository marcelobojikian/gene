#!/usr/bin/env bats
# bats file_tags=cache

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    _path global
    TEST_DIR=$(mktemp -d)
    echo "TEST_DIR: ${TEST_DIR}"
}

teardown() {
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "Invalid when option is after command" {
    run cache.sh delete --path=$TEST_DIR     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid when command without path" {
    run cache.sh delete     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Success when delete cache with path" {
    [[ -d "$TEST_DIR" ]]

    run cache.sh --path=$TEST_DIR delete
    [[ "${status}" -eq 0 ]]
    [[ ! -d "$TEST_DIR" ]]
}
