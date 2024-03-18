#!/usr/bin/env bats
# bats file_tags=server,functions

setup_file() { export TEST_DIR=$(mktemp -dp "$TMPDIR"); }
teardown_file() { rm -rf "$TEST_DIR"; }

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadMethods "global/functions.sh"
    HOST=$(testServer)
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
    echo "lines: ${lines[@]}"
}

launch() {
    echo $(cache $@)
}

@test "Sould fail when informed less than 3 parameters" {
    result=$(launch)
    [[ ! -z "$result" ]]
    [[ "${result}" == "Invalid cache parameters" ]]

    result=$(launch "$HOST")
    [[ ! -z "$result" ]]
    [[ "${result}" == "Invalid cache parameters" ]]

    result=$(launch "$HOST" "folder")
    [[ ! -z "$result" ]]
    [[ "${result}" == "Invalid cache parameters" ]]
}

@test "Should download cache.sh to use cahcing and cache a object" {

    [[ ! -f "$TEST_DIR/global/cache.sh" ]]

    result=$(launch "$HOST" "$TEST_DIR" "global/cache.sh")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]
    
    [[ "$result" == "$TEST_DIR/global/cache.sh" ]]
}

@test "Should download instruction usage" {
    
    [[ ! -f "$TEST_DIR/usage/en/cache" ]]
    
    result=$(launch "$HOST" "$TEST_DIR" "usage/en/cache")
    [[ ! -z "$result" ]]
    [[ -f "$TEST_DIR/global/cache.sh" ]]

    [[ -f "$TEST_DIR/usage/en/cache" ]]
    [[ "$result" == "$TEST_DIR/usage/en/cache" ]]

}