#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    _path global
    TEST_FILE=$(mktemp -u)
    TEST_DIR=$(mktemp -d)
    echo "TEST_DIR: ${TEST_DIR}"
}

teardown() {
    rm -f "$TEST_FILE"
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "Invalid when option is after command" {
    run cache.sh put --path=$TEST_DIR    
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid when command without path" {
    run cache.sh put     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Set cache path" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid without key parameter" {
    run cache.sh --path=$TEST_DIR put
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache put command requires two parameters" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Invalid without file parameter" {
    run cache.sh --path=$TEST_DIR put XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache put command requires two parameters" ]]
    [[ "${lines[1]}" == "Try 'gene cache -h' for more information." ]]
}

@test "Success when Set new key " {

    KEY="123/XYZ"
    FILE="$(mktemp)"  

    [[ -f "$FILE" ]]
    [[ ! -f "$TEST_DIR/$KEY" ]]

    run cache.sh --path=$TEST_DIR put $KEY "$FILE"
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "$TEST_DIR/$KEY" ]]

    [[ -f "$TEST_DIR/$KEY" ]]

}

@test "Fail when file not exist" {

    KEY="123/XYZ"
    FILE="$(mktemp -u)"  

    run cache.sh --path=$TEST_DIR put $KEY "$FILE"
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "File not found: $TEST_DIR/$KEY" ]]

}
