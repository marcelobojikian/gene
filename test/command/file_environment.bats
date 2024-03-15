#!/usr/bin/env bats
# bats file_tags=server,command

setup_file() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"

    local HOST=$(testServer)

    export ENV_EMPTY=$(getEnv "URI="        \
                              "CACHEABLE="  \
                              "CACHE_PATH=" \
                              "LOG_LEVEL="  \
                              "FILE_GLOBAL_FUNC=")

    export ENV_MIN=$(getEnv "URI=$HOST")

}

setup() {
    load "$PROJECT_ROOT/test/helpers/bats_setup"
    loadAssert
    setSrcPath
}

launch_param() { run command.sh ${@}; }
launch_env() { launch_param "--env-file=${1}" ${@:2}; }

@test "Should fail when configure file is invalid" {
    local TEST_FILE=$(mktemp -up "$TMPDIR")
    launch_env "$TEST_FILE"
    assert_failure
    assert_line "Invalid configuration file: $TEST_FILE"
}

@test "Should fail when variable URI is empty" {
    launch_env "$ENV_EMPTY"
    assert_failure
    assert_line "Unknown uri, use option --uri to set valid url."
}

@test "Should fail when URI is invalid" {
    local URI=http://invalid.uri
    launch_env $(getEnv "URI=$URI")
    assert_failure
    assert_line "Url invalida: $URI"
}

@test "Should show usage message when URI is OK" {
    launch_env "$ENV_MIN"
    assert_success
    assert_line 'Usage: gene [OPTIONS] COMMAND'
}