#!/usr/bin/env bats
# bats file_tags=server,command

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"

    export TEST_DIR_CACHE=$(mktemp -dp "$TMPDIR")

    export HOST=URI=$(testServer)
    export FILE_FUNC=FILE_GLOBAL_FUNC=$TEST_DIR_CACHE/global/functions.sh

}

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadAssert
    setSrcPath
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

launch_param() { run command.sh ${@}; }
launch_env() { launch_param "--env-file=${1}" ${@:2}; }

be_cached() { [[ -f "$TEST_DIR_CACHE/$1" ]]; }
no_cached() { [[ ! -f "$TEST_DIR_CACHE/$1" ]]; }
rm_cache() {
    [[ -f "$TEST_DIR_CACHE/$1" ]] && rm "$TEST_DIR_CACHE/$1"
    [[ -f "$TEST_DIR_CACHE/$1" ]] && return 1
    return 0
}

@test "Should download and no cached when environment without variable" {
    ENV=$(getEnv "$HOST")
    rm_cache global/functions.sh
    launch_env $ENV
    assert_success
    no_cached global/functions.sh
}

@test "Should download and no cached when environment variable is empty" {
    ENV=$(getEnv "$HOST" \
                 "FILE_GLOBAL_FUNC=")
    rm_cache global/functions.sh
    launch_env $ENV
    assert_success
    no_cached global/functions.sh
}

@test "Should download and no cached when environment variable is invalid" {
    ENV=$(getEnv "$HOST" \
                 "FILE_GLOBAL_FUNC=$(mktemp -dp "$TMPDIR")/folder/functions.sh")
    rm_cache global/functions.sh
    launch_env $ENV
    assert_success
    no_cached global/functions.sh
}

@test "Should use local when environment variable is correct" {
    ENV=$(getEnv "$HOST" \
                 "$FILE_FUNC")
    rm_cache global/functions.sh
    launch_env $ENV
    assert_success
    be_cached global/functions.sh
}