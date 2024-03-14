#!/usr/bin/env bats
# bats file_tags=functions

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    methods "global/functions.sh"
    result=
}

teardown() {
    echo "result: ${result}"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

@test "Invalid log" {
    refute log XYZ
}

@test "No show log" {
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

@test "Get log debug" {
    export LOG_LEVEL=debug
    result=$(log debug)
    [[ "${result}" == "[DEBUG]"* ]]
}

@test "Get log info" {
    export LOG_LEVEL=info
    result=$(log info)
    [[ "${result}" == "[INFO]"* ]]
}

@test "Get log warn" {
    export LOG_LEVEL=warn
    result=$(log warn)
    [[ "${result}" == "[WARN]"* ]]
}

@test "Get log error" {
    export LOG_LEVEL=error
    result=$(log error)
    [[ "${result}" == "[ERROR]"* ]]
}

@test "Get log fatal" {
    export LOG_LEVEL=fatal
    result=$(log fatal)
    [[ "${result}" == "[FATAL]"* ]]
}