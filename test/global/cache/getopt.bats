#!/usr/bin/env bats
# bats file_tags=cache

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    setPath global 
}

setup() {
    TEST_DIR=$(mktemp -d)
    echo "TEST_DIR: ${TEST_DIR}"
}

teardown() {
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "No command or option" {
    run cache.sh
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "No cache path" {
    run cache.sh XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid cache path" {
    run cache.sh -p "$(mktemp -u)" XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]

    run cache.sh --path="$(mktemp -u)" XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid command" {
    run cache.sh -p $TEST_DIR XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid command: XYZ" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
    run cache.sh --path=$TEST_DIR XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid command: XYZ" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "No command with path option " {
    run cache.sh --path="$TEST_DIR"
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}
