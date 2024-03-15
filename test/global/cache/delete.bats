#!/usr/bin/env bats
# bats file_tags=cache

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    setPath global
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "Should fail when option --path or -p is not set" {
    run cache.sh delete
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is after delete" {
    run cache.sh delete --path=ZYX
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is invalid" {
    run cache.sh -p "$(mktemp -up "$TMPDIR")" delete
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]

    run cache.sh --path="$(mktemp -up "$TMPDIR")" delete
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should delete when cache with option --path or -p" {
    TEST_DIR=$(mktemp -dp "$TMPDIR")
    [[ -d "$TEST_DIR" ]]

    run cache.sh --path=$TEST_DIR delete
    [[ "${status}" -eq 0 ]]
    [[ ! -d "$TEST_DIR" ]]

    TEST_DIR=$(mktemp -dp "$TMPDIR")
    [[ -d "$TEST_DIR" ]]

    run cache.sh -p $TEST_DIR delete
    [[ "${status}" -eq 0 ]]
    [[ ! -d "$TEST_DIR" ]]
}
