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

@test "Should get cache command key" {
    result=$(command_key cache)
    [[ "${result}" == "global/cache.sh" ]]
}

@test "Should usage cache command key" {
    result=$(command_key usage/en/cache)
    [[ "${result}" == "usage/en/cache" ]]
}

@test "Should return the same value when key is not configured" {
    result=$(command_key abc/XYZ)
    [[ "${result}" == "abc/XYZ" ]]
}