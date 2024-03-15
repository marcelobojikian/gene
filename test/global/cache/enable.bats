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
    run cache.sh enable     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is after enable" {
    run cache.sh enable --path=XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should enable when option --path or -p is already enabled" {
    TEST_DIR=$(mktemp -dp "$TMPDIR")
    [[ -d "$TEST_DIR" ]]

    run cache.sh -p "$TEST_DIR" enable
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Cache is already enabled" ]]

    run cache.sh --path="$(mktemp -dp "$TMPDIR")" enable
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Cache is already enabled" ]]
}

@test "Should enable when option --path or -p is not created yet" {
    TEST_DIR=$(mktemp -udp "$TMPDIR")
    [[ ! -d "$TEST_DIR" ]]
    run cache.sh --path=$TEST_DIR enable
    [[ "${status}" -eq 0 ]]
    [[ -d "$TEST_DIR" ]]

    TEST_DIR=$(mktemp -udp "$TMPDIR")
    [[ ! -d "$TEST_DIR" ]]
    run cache.sh -p $TEST_DIR enable
    [[ "${status}" -eq 0 ]]
    [[ -d "$TEST_DIR" ]]

}
