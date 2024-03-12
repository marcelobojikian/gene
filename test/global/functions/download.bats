#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    methods "global/functions.sh"
    HOST=$(server)
    TEST_FILE=$(mktemp -u)
    echo "TEST_FILE: ${TEST_FILE}"
}

teardown() {
    rm -f "$TEST_FILE"
    echo "result: ${result}"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

_download() {
    echo $(download $@)
}

@test "Success to download file" {
    assert download $HOST "$TEST_FILE"
    [[ "${status}" -eq 0 ]]
    [[ -f "$TEST_FILE" ]]
}

@test "Url not found" {
    result=$(_download "$HOST/usage/XXXXX" "$TEST_FILE")
    [[ ! -f "$TEST_FILE" ]]
    [[ "${result}" == *"Url not found: "* ]]
}

@test "Url invalid" {
    result=$(_download "https://invali.url" "$TEST_FILE")
    [[ ! -f "$TEST_FILE" ]]
    [[ "${result}" == *"Downloaded fail: "* ]]
}
