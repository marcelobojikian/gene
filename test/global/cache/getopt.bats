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

@test "Should fail when command or option is not informed" {
    run cache.sh
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when no command and with path option " {
    run cache.sh --path="$TMPDIR"
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is after something" {
    run cache.sh XYZ --path=ZYX
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is not set" {
    run cache.sh XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when option --path or -p is invalid" {
    run cache.sh -p "$(mktemp -up "$TMPDIR")" XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]

    run cache.sh --path="$(mktemp -up "$TMPDIR")" XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Should fail when command is invalid" {
    run cache.sh -p $TMPDIR XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid command: XYZ" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
    run cache.sh --path=$TMPDIR XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid command: XYZ" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}