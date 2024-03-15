#!/usr/bin/env bats
# bats file_tags=functions

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

@test "Should not show the log message" {
    export LOG_LEVEL=error
    result=$(log debug text)
    [[ -z $result ]]
    result=$(log info text)
    [[ -z $result ]]
    result=$(log warn text)
    [[ -z $result ]]
    result=$(log error text)
    [[ ! -z $result ]]
}

@test "Should show debug message" {
    export LOG_LEVEL=debug
    result=$(log debug)
    [[ "${result}" == "[DEBUG]"* ]]
}

@test "Should show info message" {
    export LOG_LEVEL=info
    result=$(log info)
    [[ "${result}" == "[INFO]"* ]]
}

@test "Should show warn message" {
    export LOG_LEVEL=warn
    result=$(log warn)
    [[ "${result}" == "[WARN]"* ]]
}

@test "Should show error message" {
    export LOG_LEVEL=error
    result=$(log error)
    [[ "${result}" == "[ERROR]"* ]]
}

@test "Should show fatal message" {
    export LOG_LEVEL=fatal
    result=$(log fatal)
    [[ "${result}" == "[FATAL]"* ]]
}