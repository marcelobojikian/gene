#!/usr/bin/env bats
# bats file_tags=server,functions

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
    HOST=$(testServer)
    TEST_FILE=$(mktemp -up "$TMPDIR")
}

teardown() {
    rm -f "$TEST_FILE"
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

launch() {
    echo $(download $@)
}

@test "Should download the new file" {
    download $HOST "$TEST_FILE"
    [[ "${status}" -eq 0 ]]
    [[ -f "$TEST_FILE" ]]
}

@test "Should fail when Url not found" {
    result=$(launch "$HOST/usage/XXXXX" "$TEST_FILE")
    [[ ! -f "$TEST_FILE" ]]
    [[ "${result}" == *"Url not found: "* ]]
}

@test "Should fail when Url is invalid" {
    result=$(launch "https://invali.url" "$TEST_FILE")
    [[ ! -f "$TEST_FILE" ]]
    [[ "${result}" == *"Downloaded fail: "* ]]
}
