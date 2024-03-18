#!/usr/bin/env bats
# bats file_tags=functions
setup_file() { export LOG_LEVEL=fatal; }
setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

@test "Should fail when type of log is invalid" {
    [[ $(log XYZ) ]]
}

@test "Should log debug message" {
    [[ ! $(log debug) ]]
}

@test "Should log info message" {
    [[ ! $(log info) ]]
}

@test "Should log warn message" {
    [[ ! $(log warn) ]]
}

@test "Should log error message" {
    [[ ! $(log error) ]]
}

@test "Should log fatal message" {
    [[ ! $(log fatal) ]]
}