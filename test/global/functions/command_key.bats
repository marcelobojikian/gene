#!/usr/bin/env bats

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

@test "Get Command cache" {
    result=$(command_key cache)
    [[ "${result}" == "global/cache.sh" ]]
}

@test "Get Usage cache" {
    result=$(command_key usage/en/cache)
    [[ "${result}" == "usage/en/cache" ]]
}