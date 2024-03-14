#!/usr/bin/env bats
# bats file_tags=cache

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    _path global
    TEST_FILE=$(mktemp -u)
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
    run cache.sh enable --path=$TEST_DIR
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid when command without path" {
    run cache.sh enable     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid cache path" {
    run cache.sh -p "$TEST_FILE" enable
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]

    run cache.sh --path=$TEST_FILE enable
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}
